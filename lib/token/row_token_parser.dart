import 'package:tedious_dart/token/nbcrow_token_parser.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';
import 'package:tedious_dart/value_parser.dart';

Future<RowToken> rowParser(StreamParser parser) async {
  final colMetadata = parser.colMetadata;
  final length = colMetadata!.length;
  List<Column> columns = [];

  for (int i = 0; i < length; i++) {
    final currColMetadata = colMetadata[i];
    dynamic value;
    valueParse(parser, currColMetadata, parser.options, (v) {
      value = v;
    });

    while (parser.suspended == true) {
      await parser.streamBuffer.waitForChunk();

      parser.suspended = false;
      final next = parser.next!;

      next();
    }
    columns.add(Column(value: value, metadata: currColMetadata));
  }

  if (parser.options.useColumnNames == true) {
    Map<String, Column> columnsMap = {};

    for (var column in columns) {
      final colName = column.metadata.colName;
      if (columnsMap[colName] == null) {
        columnsMap[colName] = column;
      }
    }

    return RowToken(columns: columnsMap);
  } else {
    return RowToken(columns: columns);
  }
}
