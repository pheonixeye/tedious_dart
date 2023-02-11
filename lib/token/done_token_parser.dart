// ignore_for_file: constant_identifier_names

import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

const Map<String, int> DONESTATUS = {
  'MORE': 0x0001,
  'ERROR': 0x0002,
  // This bit is not yet in use by SQL Server, so is not exposed in the returned token
  'INXACT': 0x0004,
  'COUNT': 0x0010,
  'ATTN': 0x0020,
  'SRVERROR': 0x0100
};

class DoneTokenData {
  bool? more;
  bool? sqlError;
  bool? attention;
  bool? serverError;
  num? rowCount;
  num? curCmd;

  DoneTokenData({
    this.more,
    this.attention,
    this.curCmd,
    this.rowCount,
    this.serverError,
    this.sqlError,
  });
}

parseToken(
  StreamParser parser,
  ParserOptions options,
  void Function(DoneTokenData data) callback,
) {
  parser.readUInt16LE((status) {
    final more = (status.toInt() & DONESTATUS['MORE']!.toInt()); //TODO:bool
    final sqlError =
        (status.toInt() & DONESTATUS['ERROR']!.toInt()); //TODO:bool
    final rowCountValid =
        (status.toInt() & DONESTATUS['COUNT']!.toInt()); //TODO:bool
    final attention =
        (status.toInt() & DONESTATUS['ATTN']!.toInt()); //TODO:bool
    final serverError =
        (status.toInt() & DONESTATUS['SRVERROR']!.toInt()); //TODO:bool
    //TODO: understand !! operator on int;

    parser.readUInt16LE((curCmd) {
      next(num rowCount) {
        return callback(
          DoneTokenData(
            more: more,
            sqlError: sqlError,
            attention: attention,
            serverError: serverError,
            rowCount: rowCountValid ? rowCount : null,
            curCmd: curCmd,
          ),
        );
      }

      if (TDSVERSIONS[options.tdsVersion]! < TDSVERSIONS['7_2']!) {
        parser.readUInt32LE(next);
      } else {
        parser.readBigUInt64LE((rowCount) {
          next(rowCount);
        });
      }
    });
  });
}

doneParser(
  StreamParser parser,
  ParserOptions options,
  void Function(DoneToken data) callback,
) {
  parseToken(parser, options, (data) {
    callback(DoneToken(
      more: data.more,
      serverError: data.serverError,
      sqlError: data.sqlError,
      attention: data.attention,
      rowCount: data.rowCount,
      curCmd: data.curCmd,
    ));
  });
}

doneInProcParser(
  StreamParser parser,
  ParserOptions options,
  void Function(DoneInProcToken data) callback,
) {
  parseToken(parser, options, (data) {
    callback(DoneInProcToken(
      more: data.more,
      serverError: data.serverError,
      sqlError: data.sqlError,
      attention: data.attention,
      rowCount: data.rowCount,
      curCmd: data.curCmd,
    ));
  });
}

doneProcParser(
  StreamParser parser,
  ParserOptions options,
  void Function(DoneProcToken data) callback,
) {
  parseToken(parser, options, (data) {
    callback(DoneProcToken(
      more: data.more,
      serverError: data.serverError,
      sqlError: data.sqlError,
      attention: data.attention,
      rowCount: data.rowCount,
      curCmd: data.curCmd,
    ));
  });
}
