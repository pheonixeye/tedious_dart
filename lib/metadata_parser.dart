import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';

class XmlSchema {
  String dbname;
  String owningSchema;
  String xmlSchemaCollection;

  XmlSchema({
    required this.dbname,
    required this.owningSchema,
    required this.xmlSchemaCollection,
  });
}

class UdtInfo {
  num maxByteSize;
  String dbname;
  String owningSchema;
  String typeName;
  String assemblyName;

  UdtInfo({
    required this.maxByteSize,
    required this.dbname,
    required this.owningSchema,
    required this.typeName,
    required this.assemblyName,
  });
}

class BaseMetadata {
  late num userType;

  late num flags;

  late DataType type;

  Collation? collation;

  num? precision;

  num? scale;

  num? dataLength;

  XmlSchema? schema;

  UdtInfo? udtInfo;

  BaseMetadata({
    required this.userType,
    this.collation,
    this.dataLength,
    required this.flags,
    this.precision,
    this.scale,
    this.schema,
    required this.type,
    this.udtInfo,
  });
}

class Metadata {
  CryptoMetadata? cryptoMetadata;
  BaseMetadata? baseMetadata;

  Metadata({
    this.baseMetadata,
    this.cryptoMetadata,
  });
}
