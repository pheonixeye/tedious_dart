import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

void orderParser(
  StreamParser parser,
  ParserOptions options,
  void Function(OrderToken token) callback,
) {
  parser.readUInt16LE((length) {
    final columnCount = length / 2;
    List<num> orderColumns = [];

    int i = 0;
    next(void Function() done) {
      if (i == columnCount) {
        return done();
      }

      parser.readUInt16LE((column) {
        orderColumns.add(column);

        i++;

        next(done);
      });
    }

    next(() {
      callback(OrderToken(columns: orderColumns));
    });
  });
}
