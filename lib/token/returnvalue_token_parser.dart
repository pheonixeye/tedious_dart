import 'package:tedious_dart/metadata_parser.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';
import 'package:tedious_dart/value_parser.dart';

void returnValueParser(
  StreamParser parser,
  ParserOptions options,
  void Function(ReturnValueToken token) callback,
) {
  parser.readUInt16LE((paramOrdinal) {
    parser.readBVarChar((paramName) {
      if (paramName.startsWith(RegExp('@'))) {
        paramName = paramName.substring(1);
      }

      // status
      parser.readUInt8((_) {
        metadataParse(parser, options, (metadata) {
          valueParse(parser, metadata, options, (value) {
            callback(ReturnValueToken(
              paramOrdinal: paramOrdinal,
              paramName: paramName,
              metadata: metadata,
              value: value,
            ));
          });
        });
      });
    });
  });
}
