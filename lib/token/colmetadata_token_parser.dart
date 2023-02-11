import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/metadata_parser.dart';
import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

class ColumnMetadata extends Metadata {
  String colName;

  dynamic tableName;
  // string | List<string> | undefined;
  ColumnMetadata({
    required this.colName,
    this.tableName,
    super.baseMetadata,
    super.cryptoMetadata,
  });
}

readTableName(
  StreamParser parser,
  ParserOptions options,
  Metadata metadata,
  void Function(dynamic tableName) callback, //tableName = String | List<String>
) {
  if (metadata.baseMetadata!.type.hasTableName == true) {
    if (TDSVERSIONS[options.tdsVersion]! >= TDSVERSIONS['7_2']!) {
      parser.readUInt8((numberOfTableNameParts) {
        List<String> tableName = [];

        var i = 0;
        next(void Function() done) {
          if (numberOfTableNameParts == i) {
            return done();
          }

          parser.readUsVarChar((part) {
            tableName.add(part);
            i++;
            next(done);
          });
        }

        next(() {
          callback(tableName);
        });
      });
    } else {
      parser.readUsVarChar(callback);
    }
  } else {
    callback(null);
  }
}

readColumnName(
  StreamParser parser,
  ParserOptions options,
  num index,
  Metadata metadata,
  void Function(String colName) callback,
) {
  parser.readBVarChar((colName) {
    if (options.columnNameReplacer != null) {
      callback(options.columnNameReplacer!(
          colName: colName, index: index, metadata: metadata)!);
    } else if (options.camelCaseColumns == true) {
      callback(colName.replaceAllMapped(RegExp('/^[A-Z]/'), (s) {
        return s.input.toLowerCase();
      }));
    } else {
      callback(colName);
    }
  });
}

readColumn(
  StreamParser parser,
  ParserOptions options,
  num index,
  void Function(ColumnMetadata column) callback,
) {
  metadataParse(parser, options, (metadata) {
    readTableName(parser, options, metadata, (tableName) {
      readColumnName(parser, options, index, metadata, (colName) {
        callback(
          ColumnMetadata(
            colName: colName,
            tableName: tableName,
            baseMetadata: BaseMetadata(
              userType: metadata.baseMetadata!.userType,
              flags: metadata.baseMetadata!.flags,
              type: metadata.baseMetadata!.type,
              collation: metadata.baseMetadata!.collation,
              precision: metadata.baseMetadata!.precision,
              scale: metadata.baseMetadata!.scale,
              udtInfo: metadata.baseMetadata!.udtInfo,
              dataLength: metadata.baseMetadata!.dataLength,
              schema: metadata.baseMetadata!.schema,
            ),
            cryptoMetadata: CryptoMetadata(),
          ),
        );
      });
    });
  });
}

Future<ColMetadataToken> colMetadataParser(StreamParser parser) async {
  while (parser.buffer!.length - (parser.position!) < 2) {
    await parser.streamBuffer.waitForChunk();
  }

  final columnCount = parser.buffer!.readUInt16LE(parser.position as int);

  parser.setPosition(parser.position! + 2);

  List<ColumnMetadata> columns = [];
  for (int i = 0; i < columnCount; i++) {
    late ColumnMetadata column;

    readColumn(parser, parser.options, i, (c) {
      column = c;
    });

    while (parser.suspended == true) {
      await parser.streamBuffer.waitForChunk();

      parser.suspended = false;
      final next = parser.next!;

      next();
    }

    columns.add(column);
  }

  return ColMetadataToken(columns: columns);
}
