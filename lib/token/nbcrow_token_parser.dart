import 'package:tedious_dart/token/colmetadata_token_parser.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';
import 'package:tedious_dart/extensions/bracket_on_buffer.dart';
import 'package:tedious_dart/value_parser.dart';

nullHandler(
  StreamParser parser,
  ColumnMetadata columnMetadata,
  ParserOptions options,
  void Function(dynamic data) callback,
) {
  callback(null);
}

class Column {
  dynamic value;
  ColumnMetadata metadata;
  Column({
    this.value,
    required this.metadata,
  });
}

Future<NBCRowToken> nbcRowParser(StreamParser parser) async {
  final colMetadata = parser.colMetadata;
  final bitmapByteLength = (colMetadata!.length / 8).ceil();
  List<Column> columns = [];
  List<bool> bitmap = [];

  while (parser.buffer!.length - (parser.position as int) < bitmapByteLength) {
    await parser.streamBuffer.waitForChunk();
  }

  final bytes = parser.buffer!.slice(
      parser.position as int, (parser.position! + bitmapByteLength) as int);

  parser.setPosition(parser.position! + bitmapByteLength);
  for (int i = 0, len = bytes.length; i < len; i++) {
    int byte = bytes[i];

    // byte & (0x1 as int) != 0 ? bitmap.add(true) : bitmap.add(false);
    bitmap.add(byte & 0x1 != 0 ? true : false);
    bitmap.add(byte & 0x10 != 0 ? true : false);
    bitmap.add(byte & 0x100 != 0 ? true : false);
    bitmap.add(byte & 0x1000 != 0 ? true : false);
    bitmap.add(byte & 0x10000 != 0 ? true : false);
    bitmap.add(byte & 0x100000 != 0 ? true : false);
    bitmap.add(byte & 0x1000000 != 0 ? true : false);
    bitmap.add(byte & 0x10000000 != 0 ? true : false);
    //TODO:
  }

  for (int i = 0; i < colMetadata.length; i++) {
    final currColMetadata = colMetadata[i];
    dynamic value;
    bitmap[i] == true
        ? nullHandler(parser, currColMetadata, parser.options, (v) {
            value = v;
          })
        : valueParse(parser, currColMetadata, parser.options, (v) {
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
    final Map<String, Column> columnsMap = {};

    for (var column in columns) {
      final colName = column.metadata.colName;
      if (columnsMap[colName] == null) {
        columnsMap[colName] = column;
      }
    }

    return NBCRowToken(columns: columnsMap);
  } else {
    return NBCRowToken(columns: columns);
  }
}
