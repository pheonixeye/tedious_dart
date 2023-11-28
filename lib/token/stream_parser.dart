import 'dart:async';
import 'dart:math';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_const_typedef.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/token/colmetadata_token_parser.dart';
import 'package:tedious_dart/token/done_token_parser.dart';
import 'package:tedious_dart/token/env_change_token_parser.dart';
import 'package:tedious_dart/token/feature_ext_ack_parser.dart';
import 'package:tedious_dart/token/fedauth_info_parser.dart';
import 'package:tedious_dart/token/infoerror_token_parser.dart';
import 'package:tedious_dart/token/loginack_token_parser.dart';
import 'package:tedious_dart/token/nbcrow_token_parser.dart';
import 'package:tedious_dart/token/order_token_parser.dart';
import 'package:tedious_dart/token/returnstatus_token_parser.dart';
import 'package:tedious_dart/token/returnvalue_token_parser.dart';
import 'package:tedious_dart/token/row_token_parser.dart';
import 'package:tedious_dart/token/sspi_token_parser.dart';
import 'package:tedious_dart/token/token.dart';

final Map<int, Function> tokenParsers = {
  TOKEN_TYPE["DONE"]!: doneParser,
  TOKEN_TYPE["DONEINPROC"]!: doneInProcParser,
  TOKEN_TYPE["DONEPROC"]!: doneProcParser,
  TOKEN_TYPE["ENVCHANGE"]!: envChangeParser,
  TOKEN_TYPE["ERROR"]!: errorParser,
  TOKEN_TYPE["FEDAUTHINFO"]!: fedAuthInfoParser,
  TOKEN_TYPE["FEATUREEXTACK"]!: featureExtAckParser,
  TOKEN_TYPE["INFO"]!: infoParser,
  TOKEN_TYPE["LOGINACK"]!: loginAckParser,
  TOKEN_TYPE["ORDER"]!: orderParser,
  TOKEN_TYPE["RETURNSTATUS"]!: returnStatusParser,
  TOKEN_TYPE["RETURNVALUE"]!: returnValueParser,
  TOKEN_TYPE["SSPI"]!: sspiParser
};

class ParserOptions {
  bool? useUTC;

  bool? lowerCaseGuids;

  String? tdsVersion;

  bool? useColumnNames;

  ColumnNameReplacer? columnNameReplacer;

  bool? camelCaseColumns;
  ParserOptions({
    this.camelCaseColumns,
    this.columnNameReplacer,
    this.lowerCaseGuids,
    this.tdsVersion,
    this.useColumnNames,
    this.useUTC,
  });
}

class StreamBuffer {
  //AsyncIterator<Buffer, any, undefined> | Iterator<Buffer, any, undefined>;
  StreamIterator<Buffer> iterator;
  Buffer buffer;
  int position;

  StreamBuffer({
    required Stream<Buffer> iterable,
  })  : iterator = StreamIterator(iterable),
        buffer = Buffer.alloc(0),
        position = 0;

  Future<void> waitForChunk() async {
    final result = await iterator.moveNext();
    if (!result) {
      throw MTypeError('unexpected end of data');
    }

    if (position == buffer.length) {
      buffer = iterator.current;
    } else {
      buffer = Buffer.concat([buffer.slice(position), iterator.current]);
    }
    position = 0;
    console.log(['waitForChunk();']);
  }
}

class StreamParser {
  final StreamBuffer streamBuffer;
  final Debug debug;
  final ParserOptions options;
  List<ColumnMetadata> colMetadata;
  bool suspended;
  void Function()? next;

  StreamParser({
    required this.streamBuffer,
    required this.debug,
    required this.options,
  })  : colMetadata = [],
        suspended = false,
        next = null;

  static Stream<Token?> parseTokens({
    required Stream<Buffer> iterable,
    required Debug debug,
    required ParserOptions options,
    List<ColumnMetadata> colMetadata = const [],
  }) async* {
    late Token? token;

    void onDoneParsing(Token? t) {
      token = t;
    }

    final streamBuffer = StreamBuffer(
      iterable: iterable,
    );

    final parser = StreamParser(
      streamBuffer: streamBuffer,
      debug: debug,
      options: options,
    );

    parser.colMetadata = colMetadata;

    while (true) {
      try {
        await streamBuffer.waitForChunk();
      } catch (err) {
        if (streamBuffer.position == streamBuffer.buffer.length) {
          return;
        }

        rethrow;
      }

      if (parser.suspended) {
        // Unsuspend and continue from where ever we left off.
        parser.suspended = false;
        final next = parser.next!;

        next();

        // Check if a new token was parsed after unsuspension.
        if (!parser.suspended && token != null) {
          if (token is ColMetadataToken) {
            parser.colMetadata = (token! as ColMetadataToken).columns;
          }
          yield token;
        }
      }

      while (
          !parser.suspended && (parser.position + 1 <= parser.buffer.length)) {
        final type = parser.buffer.readUInt8(parser.position);
        print(type);
        parser.setPosition(parser.position + 1);

        if (type == TOKEN_TYPE['COLMETADATA']!) {
          final token = await colMetadataParser(parser);
          parser.colMetadata = token.columns;
          yield token;
        } else if (type == TOKEN_TYPE['ROW']) {
          yield await rowParser(parser);
        } else if (type == TOKEN_TYPE['NBCROW']) {
          yield await nbcRowParser(parser);
        } else if (tokenParsers[type] != null) {
          tokenParsers[type]!(parser, parser.options, onDoneParsing);

          // Check if a new token was parsed after unsuspension.
          if (parser.suspended == false && token != null) {
            if (token is ColMetadataToken) {
              parser.colMetadata = (token as ColMetadataToken).columns;
            }
            yield token;
          }
        } else {
          throw MTypeError('Unknown type: $type');
        }
      }
      console.log(['parseTokens();']);
    }
  }

  Buffer get buffer {
    return streamBuffer.buffer;
  }

  int get position {
    return streamBuffer.position;
  }

  void setPosition(int value) {
    streamBuffer.position = value;
  }

  suspend(void Function() next) {
    suspended = true;
    this.next = next;
  }

  awaitData(int length, void Function() callback) {
    if (position + length <= buffer.length) {
      callback();
    } else {
      suspend(() {
        awaitData(length, callback);
      });
    }
  }

  readInt8(void Function(int data) callback) {
    awaitData(1, () {
      final data = buffer.readInt8(position);
      setPosition(position + 1);
      callback(data);
    });
  }

  readUInt8(void Function(int data) callback) {
    awaitData(1, () {
      final data = buffer.readUInt8(position);
      setPosition(position + 1);
      callback(data);
    });
  }

  readInt16LE(void Function(int data) callback) {
    awaitData(2, () {
      final data = buffer.readInt16LE(position);
      setPosition(position + 2);
      callback(data);
    });
  }

  readInt16BE(void Function(int data) callback) {
    awaitData(2, () {
      final data = buffer.readInt16BE(position);
      setPosition(position + 2);
      callback(data);
    });
  }

  readUInt16LE(void Function(int data) callback) {
    awaitData(2, () {
      final data = buffer.readUInt16LE(position);
      setPosition(position + 2);
      callback(data);
    });
  }

  readUInt16BE(void Function(int data) callback) {
    awaitData(2, () {
      final data = buffer.readUInt16BE(position);
      setPosition(position + 2);
      callback(data);
    });
  }

  readInt32LE(void Function(int data) callback) {
    awaitData(4, () {
      final data = buffer.readInt32LE(position);
      setPosition(position + 4);
      callback(data);
    });
  }

  readInt32BE(void Function(int data) callback) {
    awaitData(4, () {
      final data = buffer.readInt32BE(position);
      setPosition(position + 4);
      callback(data);
    });
  }

  readUInt32LE(void Function(int data) callback) {
    awaitData(4, () {
      final data = buffer.readUInt32LE(position);
      setPosition(position + 4);
      callback(data);
    });
  }

  readUInt32BE(void Function(int data) callback) {
    awaitData(4, () {
      final data = buffer.readUInt32BE(position);
      setPosition(position + 4);
      callback(data);
    });
  }

  readBigInt64LE(void Function(int data) callback) {
    awaitData(8, () {
      final data = buffer.readBigInt64LE(position);
      setPosition(position + 8);
      callback(data.toInt());
    });
  }

  readInt64LE(void Function(int data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer.readInt32LE(position + 4) +
          ((buffer[position + 4] & 0x80) == 0x80 ? 1 : -1) *
              buffer.readUInt32LE(position);
      setPosition(position + 8);
      callback(data.toInt());
    });
  }

  readInt64BE(void Function(int data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer.readInt32BE(position) +
          ((buffer[position] & 0x80) == 0x80 ? 1 : -1) *
              buffer.readUInt32BE(position + 4);
      setPosition(position + 8);
      callback(data.toInt());
    });
  }

  readBigUInt64LE(void Function(int data) callback) {
    awaitData(8, () {
      final data = buffer.readBigUInt64LE(position);
      setPosition(position + 8);
      callback(data.toInt());
    });
  }

  readUInt64LE(void Function(int data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer.readUInt32LE(position + 4) +
          buffer.readUInt32LE(position);
      setPosition(position + 8);
      callback(data.toInt());
    });
  }

  readUInt64BE(void Function(int data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer.readUInt32BE(position) +
          buffer.readUInt32BE(position + 4);
      setPosition(position + 8);
      callback(data.toInt());
    });
  }

  readFloatLE(void Function(int data) callback) {
    awaitData(4, () {
      final data = buffer.readFloatLE(position);
      setPosition(position + 4);
      callback(data);
    });
  }

  readFloatBE(void Function(int data) callback) {
    awaitData(4, () {
      final data = buffer.readFloatBE(position);
      setPosition(position + 4);
      callback(data);
    });
  }

  readDoubleLE(void Function(int data) callback) {
    awaitData(8, () {
      final data = buffer.readDoubleLE(position);
      setPosition(position + 8);
      callback(data);
    });
  }

  readDoubleBE(void Function(int data) callback) {
    awaitData(8, () {
      final data = buffer.readDoubleBE(position);
      setPosition(position + 8);
      callback(data);
    });
  }

  readUInt24LE(void Function(int data) callback) {
    awaitData(3, () {
      final low = buffer.readUInt16LE(position);
      final high = buffer.readUInt8(position + 2);
      setPosition(position + 3);
      callback((low) | ((high) << 16));
    });
  }

  readUInt40LE(void Function(int data) callback) {
    awaitData(5, () {
      final low = buffer.readUInt32LE(position);
      final high = buffer.readUInt8(position + 4);
      setPosition(position + 5);
      callback((0x100000000 * high) + low);
    });
  }

  readUinteric64LE(void Function(int data) callback) {
    awaitData(8, () {
      final low = buffer.readUInt32LE(position);
      final high = buffer.readUInt32LE(position + 4);
      setPosition(position + 8);
      callback((0x100000000 * high) + low);
    });
  }

  readUinteric96LE(void Function(int data) callback) {
    awaitData(12, () {
      final dword1 = buffer.readUInt32LE(position);
      final dword2 = buffer.readUInt32LE(position + 4);
      final dword3 = buffer.readUInt32LE(position + 8);
      setPosition(position + 12);
      callback(dword1 +
          (0x100000000 * dword2) +
          (0x100000000 * 0x100000000 * dword3));
    });
  }

  readUinteric128LE(void Function(int data) callback) {
    awaitData(16, () {
      final dword1 = buffer.readUInt32LE(position);
      final dword2 = buffer.readUInt32LE(position + 4);
      final dword3 = buffer.readUInt32LE(position + 8);
      final dword4 = buffer.readUInt32LE(position + 12);
      setPosition(position + 16);
      callback(dword1 +
          (0x100000000 * dword2) +
          (0x100000000 * 0x100000000 * dword3) +
          (0x100000000 * 0x100000000 * 0x100000000 * dword4));
    });
  }

  readBuffer(int length, void Function(Buffer data) callback) {
    awaitData(length, () {
      final data = buffer.slice(position, position + length);
      setPosition(position + length);
      callback(data);
    });
  }

  readBVarChar(void Function(String data) callback) {
    readUInt8((length) {
      readBuffer(length * 2, (data) {
        callback(data.toString_({'encoding': 'ucs2'}));
      });
    });
  }

  readUsVarChar(void Function(String data) callback) {
    readUInt16LE((length) {
      readBuffer(length * 2, (data) {
        callback(data.toString_({'encoding': 'ucs2'}));
      });
    });
  }

  readBVarByte(void Function(Buffer data) callback) {
    readUInt8((length) {
      readBuffer(length, callback);
    });
  }

  readUsVarByte(void Function(Buffer data) callback) {
    readUInt16LE((length) {
      readBuffer(length, callback);
    });
  }
}
