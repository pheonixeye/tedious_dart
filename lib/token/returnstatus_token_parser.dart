import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

returnStatusParser(
  StreamParser parser,
  ParserOptions options,
  void Function(ReturnStatusToken token) callback,
) {
  parser.readInt32LE((value) {
    callback(ReturnStatusToken(value: value));
  });
}
