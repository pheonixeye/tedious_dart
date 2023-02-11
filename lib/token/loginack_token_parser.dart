import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

const interfaceTypes = {
  0: 'SQL_DFLT',
  1: 'SQL_TSQL',
};

loginAckParser(
  StreamParser parser,
  ParserOptions options,
  void Function(LoginAckToken data) callback,
) {
  parser.readUInt16LE((_) {
    parser.readUInt8((interfaceNumber) {
      final interfaceType = interfaceTypes[interfaceNumber];
      parser.readUInt32BE((tdsVersionNumber) {
        final tdsVersion = versionsByValue[tdsVersionNumber]!;
        parser.readBVarChar((progName) {
          parser.readUInt8((major) {
            parser.readUInt8((minor) {
              parser.readUInt8((buildNumHi) {
                parser.readUInt8((buildNumLow) {
                  callback(LoginAckToken(
                    interface: interfaceType!,
                    tdsVersion: tdsVersion,
                    progName: progName,
                    progVersion: ProgVersion(
                        major: major,
                        minor: minor,
                        buildNumHi: buildNumHi,
                        buildNumLow: buildNumLow),
                  ));
                });
              });
            });
          });
        });
      });
    });
  });
}
