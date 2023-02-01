import 'package:tedious_dart/metadata_parser.dart';

class ColumnMetadata extends Metadata {
  String colName;

  dynamic tableName;
  // string | List<string> | undefined;
  ColumnMetadata({
    required this.colName,
    this.tableName,
  });
}
