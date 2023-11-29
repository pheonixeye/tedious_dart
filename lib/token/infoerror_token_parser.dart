import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

class InfoErrorTokenData {
  num? number;
  num? state;
  num? Class;
  String? message;
  String? serverName;
  String? procName;
  num? lineNumber;

  InfoErrorTokenData({
    this.Class,
    this.lineNumber,
    this.message,
    this.number,
    this.procName,
    this.serverName,
    this.state,
  });
}

void parseToken(
  StreamParser parser,
  ParserOptions options,
  void Function(InfoErrorTokenData data) callback,
) {
  parser.readUInt16LE((_) {
    parser.readUInt32LE((number) {
      parser.readUInt8((state) {
        parser.readUInt8((clazz) {
          parser.readUsVarChar((message) {
            parser.readBVarChar((serverName) {
              parser.readBVarChar((procName) {
                (TDSVERSIONS[options.tdsVersion]! < TDSVERSIONS['7_2']!)
                    ? parser.readUInt16LE.call((lineNumber) {
                        callback(InfoErrorTokenData(
                            number: number,
                            state: state,
                            Class: clazz,
                            message: message,
                            serverName: serverName,
                            procName: procName,
                            lineNumber: lineNumber));
                      })
                    : parser.readUInt32LE.call((lineNumber) {
                        callback(InfoErrorTokenData(
                            number: number,
                            state: state,
                            Class: clazz,
                            message: message,
                            serverName: serverName,
                            procName: procName,
                            lineNumber: lineNumber));
                      });
              });
            });
          });
        });
      });
    });
  });
}

void infoParser(
  StreamParser parser,
  ParserOptions options,
  void Function(InfoMessageToken data) callback,
) {
  parseToken(parser, options, (data) {
    callback(InfoMessageToken(
      number: data.number!,
      state: data.state!,
      clazz: data.Class!,
      message: data.message!,
      serverName: data.serverName!,
      procName: data.procName!,
      lineNumber: data.lineNumber!,
    ));
  });
}

void errorParser(
  StreamParser parser,
  ParserOptions options,
  void Function(ErrorMessageToken data) callback,
) {
  parseToken(parser, options, (data) {
    callback(ErrorMessageToken(
      number: data.number!,
      state: data.state!,
      clazz: data.Class!,
      message: data.message!,
      serverName: data.serverName!,
      procName: data.procName!,
      lineNumber: data.lineNumber!,
    ));
  });
}
