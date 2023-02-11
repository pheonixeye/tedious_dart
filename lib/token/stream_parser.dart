import 'dart:async';
import 'dart:math';

import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/connection.dart' show ColumnNameReplacer;
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/token/colmetadata_token_parser.dart';
import 'package:tedious_dart/token/nbcrow_token_parser.dart';
import 'package:tedious_dart/token/row_token_parser.dart';
import 'package:tedious_dart/token/token.dart';
import 'package:tedious_dart/extensions/write_big_int64.dart';
import 'package:tedious_dart/extensions/bracket_on_buffer.dart';

const Map<int, Function> tokenParsers = {};

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
  late StreamIterator<Buffer>? iterator;
  //AsyncIterator<Buffer, any, undefined> | Iterator<Buffer, any, undefined>;
  Buffer? buffer;
  num? position;

  StreamBuffer({
    this.buffer,
    this.iterator,
    this.position,
    Stream<Buffer>? iterable,
  }) {
    iterator = StreamIterator(iterable!);
    buffer = Buffer.alloc(0);
    position = 0;
  }

  waitForChunk() async {
    final result = await iterator!.moveNext();
    if (result) {
      throw MTypeError('unexpected end of data');
    }

    if (position as int == buffer!.length) {
      buffer = iterator!.current;
    } else {
      buffer =
          Buffer.concat([buffer!.slice(position as int), iterator!.current]);
    }
    position = 0;
  }
}

class StreamParser {
  Debug debug;
  late List<ColumnMetadata>? colMetadata;
  ParserOptions options;
  late bool? suspended;
  late void Function()? next;
  StreamBuffer streamBuffer;

  StreamParser({
    required this.debug,
    required this.streamBuffer,
    required this.options,
  }) {
    colMetadata = [];
    suspended = false;
    next = null;
  }

  static parseTokens({
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
        if (streamBuffer.position == streamBuffer.buffer!.length) {
          return;
        }

        rethrow;
      }

      if (parser.suspended == true) {
        // Unsuspend and continue from where ever we left off.
        parser.suspended = false;
        final next = parser.next!;

        next();

        // Check if a new token was parsed after unsuspension.
        if (!parser.suspended! && token != null) {
          if (token is ColMetadataToken) {
            parser.colMetadata = (token! as ColMetadataToken).columns;
          }
          yield token;
        }
      }

      while (parser.suspended == false &&
          parser.position! + 1 <= parser.buffer!.length) {
        final type = parser.buffer!.readUInt8(parser.position as int);

        parser.setPosition(parser.position! + 1);

        if (type == TOKEN_TYPE['COLMETADATA']!) {
          final token = await colMetadataParser(parser);
          parser.colMetadata = token.columns;
          yield token;
        } else if (type == TOKEN_TYPE['ROW']) {
          yield rowParser(parser);
        } else if (type == TOKEN_TYPE['NBCROW']) {
          yield nbcRowParser(parser);
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
    }
  }

  Buffer? get buffer {
    return streamBuffer.buffer;
  }

  num? get position {
    return streamBuffer.position;
  }

  void setPosition(value) {
    streamBuffer.position = value;
  }

  suspend(void Function() next) {
    suspended = true;
    this.next = next;
  }

  awaitData(num length, void Function() callback) {
    if (position! + length <= buffer!.length) {
      callback();
    } else {
      suspend(() {
        awaitData(length, callback);
      });
    }
  }

  readInt8(void Function(num data) callback) {
    awaitData(1, () {
      final data = buffer!.readInt8(position as int);
      setPosition(position! + 1);
      // this.position += 1;
      callback(data);
    });
  }

  readUInt8(void Function(num data) callback) {
    awaitData(1, () {
      final data = buffer!.readUInt8(position as int);
      setPosition(position! + 1);
      callback(data);
    });
  }

  readInt16LE(void Function(num data) callback) {
    awaitData(2, () {
      final data = buffer!.readInt16LE(position as int);
      setPosition(position! + 2);
      callback(data);
    });
  }

  readInt16BE(void Function(num data) callback) {
    awaitData(2, () {
      final data = buffer!.readInt16BE(position as int);
      setPosition(position! + 2);
      callback(data);
    });
  }

  readUInt16LE(void Function(num data) callback) {
    awaitData(2, () {
      final data = buffer!.readUInt16LE(position as int);
      setPosition(position! + 2);
      callback(data);
    });
  }

  readUInt16BE(void Function(num data) callback) {
    awaitData(2, () {
      final data = buffer!.readUInt16BE(position as int);
      setPosition(position! + 2);
      callback(data);
    });
  }

  readInt32LE(void Function(num data) callback) {
    awaitData(4, () {
      final data = buffer!.readInt32LE(position as int);
      setPosition(position! + 4);
      callback(data);
    });
  }

  readInt32BE(void Function(num data) callback) {
    awaitData(4, () {
      final data = buffer!.readInt32BE(position as int);
      setPosition(position! + 4);
      callback(data);
    });
  }

  readUInt32LE(void Function(num data) callback) {
    awaitData(4, () {
      final data = buffer!.readUInt32LE(position as int);
      setPosition(position! + 4);
      callback(data);
    });
  }

  readUInt32BE(void Function(num data) callback) {
    awaitData(4, () {
      final data = buffer!.readUInt32BE(position as int);
      setPosition(position! + 4);
      callback(data);
    });
  }

  readBigInt64LE(void Function(num data) callback) {
    awaitData(8, () {
      final data = buffer!.readBigInt64LE(position as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readInt64LE(void Function(num data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer!.readInt32LE(position! + 4 as int) +
          ((buffer![position! + 4 as int] & 0x80) == 0x80 ? 1 : -1) *
              buffer!.readUInt32LE(position as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readInt64BE(void Function(num data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer!.readInt32BE(position as int) +
          ((buffer![position as int] & 0x80) == 0x80 ? 1 : -1) *
              buffer!.readUInt32BE(position! + 4 as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readBigUInt64LE(void Function(num data) callback) {
    awaitData(8, () {
      final data = buffer!.readBigUInt64LE(position as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readUInt64LE(void Function(num data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer!.readUInt32LE(position! + 4 as int) +
          buffer!.readUInt32LE(position as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readUInt64BE(void Function(num data) callback) {
    awaitData(8, () {
      final data = pow(2, 32) * buffer!.readUInt32BE(position as int) +
          buffer!.readUInt32BE(position! + 4 as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readFloatLE(void Function(num data) callback) {
    awaitData(4, () {
      final data = buffer!.readFloatLE(position as int);
      setPosition(position! + 4);
      callback(data);
    });
  }

  readFloatBE(void Function(num data) callback) {
    awaitData(4, () {
      final data = buffer!.readFloatBE(position as int);
      setPosition(position! + 4);
      callback(data);
    });
  }

  readDoubleLE(void Function(num data) callback) {
    awaitData(8, () {
      final data = buffer!.readDoubleLE(position as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readDoubleBE(void Function(num data) callback) {
    awaitData(8, () {
      final data = buffer!.readDoubleBE(position as int);
      setPosition(position! + 8);
      callback(data);
    });
  }

  readUInt24LE(void Function(num data) callback) {
    awaitData(3, () {
      final low = buffer!.readUInt16LE(position as int);
      final high = buffer!.readUInt8(position! + 2 as int);
      setPosition(position! + 3);
      callback((low as int) | ((high as int) << 16));
    });
  }

  readUInt40LE(void Function(num data) callback) {
    awaitData(5, () {
      final low = buffer!.readUInt32LE(position as int);
      final high = buffer!.readUInt8(position! + 4 as int);
      setPosition(position! + 5);
      callback((0x100000000 * high) + low);
    });
  }

  readUNumeric64LE(void Function(num data) callback) {
    awaitData(8, () {
      final low = buffer!.readUInt32LE(position as int);
      final high = buffer!.readUInt32LE(position! + 4 as int);
      setPosition(position! + 8);
      callback((0x100000000 * high) + low);
    });
  }

  readUNumeric96LE(void Function(num data) callback) {
    awaitData(12, () {
      final dword1 = buffer!.readUInt32LE(position as int);
      final dword2 = buffer!.readUInt32LE(position! + 4 as int);
      final dword3 = buffer!.readUInt32LE(position! + 8 as int);
      setPosition(position! + 12);
      callback(dword1 +
          (0x100000000 * dword2) +
          (0x100000000 * 0x100000000 * dword3));
    });
  }

  readUNumeric128LE(void Function(num data) callback) {
    awaitData(16, () {
      final dword1 = buffer!.readUInt32LE(position as int);
      final dword2 = buffer!.readUInt32LE(position! + 4 as int);
      final dword3 = buffer!.readUInt32LE(position! + 8 as int);
      final dword4 = buffer!.readUInt32LE(position! + 12 as int);
      setPosition(position! + 16);
      callback(dword1 +
          (0x100000000 * dword2) +
          (0x100000000 * 0x100000000 * dword3) +
          (0x100000000 * 0x100000000 * 0x100000000 * dword4));
    });
  }

  readBuffer(num length, void Function(Buffer data) callback) {
    awaitData(length, () {
      final data = buffer!.slice(position as int, position! + length as int);
      setPosition(position! + length);
      callback(data);
    });
  }

  readBVarChar(void Function(String data) callback) {
    readUInt8((length) {
      readBuffer(length * 2, (data) {
        callback(data.toString('ucs2'));
      });
    });
  }

  readUsVarChar(void Function(String data) callback) {
    readUInt16LE((length) {
      readBuffer(length * 2, (data) {
        callback(data.toString('ucs2'));
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
