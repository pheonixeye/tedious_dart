// ignore_for_file: void_checks

import 'package:sprintf/sprintf.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/token/stream_parser.dart';

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

void readCollation(
  StreamParser parser,
  void Function(Collation collation) callback,
) {
  parser.readBuffer(5, (collationData) {
    callback(Collation.fromBuffer(collationData));
  });
}

void readSchema(
  StreamParser parser,
  void Function(XmlSchema? schema) callback,
) {
  parser.readUInt8((schemaPresent) {
    if (schemaPresent == 0x01) {
      parser.readBVarChar((dbname) {
        parser.readBVarChar((owningSchema) {
          parser.readUsVarChar((xmlSchemaCollection) {
            callback(XmlSchema(
                dbname: dbname,
                owningSchema: owningSchema,
                xmlSchemaCollection: xmlSchemaCollection));
          });
        });
      });
    } else {
      callback(null);
    }
  });
}

void readUDTInfo(
  StreamParser parser,
  void Function(UdtInfo? udtInfo) callback,
) {
  parser.readUInt16LE((maxByteSize) {
    parser.readBVarChar((dbname) {
      parser.readBVarChar((owningSchema) {
        parser.readBVarChar((typeName) {
          parser.readUsVarChar((assemblyName) {
            callback(UdtInfo(
              maxByteSize: maxByteSize,
              dbname: dbname,
              owningSchema: owningSchema,
              typeName: typeName,
              assemblyName: assemblyName,
            ));
          });
        });
      });
    });
  });
}

metadataParse(
  StreamParser parser,
  ParserOptions options,
  void Function(Metadata metadata) callback,
) {
  if (TDSVERSIONS[options.tdsVersion]! < TDSVERSIONS['7_2']!) {
    parser.readUInt16LE((userType) {
      parser.readUInt16LE((flags) {
        parser.readUInt8((typeNumber) {
          DataType? type = DATATYPES[typeNumber];

          if (type == null) {
            throw MTypeError(
                sprintf('Unrecognised data type 0x%02X', typeNumber));
          }

          switch (type.name) {
            case 'Null':
            case 'TinyInt':
            case 'SmallInt':
            case 'Int':
            case 'BigInt':
            case 'Real':
            case 'Float':
            case 'SmallMoney':
            case 'Money':
            case 'Bit':
            case 'SmallDateTime':
            case 'DateTime':
            case 'Date':
              return callback(
                Metadata(
                  baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: null,
                      schema: null,
                      udtInfo: null),
                ),
              );

            case 'IntN':
            case 'FloatN':
            case 'MoneyN':
            case 'BitN':
            case 'UniqueIdentifier':
            case 'DateTimeN':
              return parser.readUInt8((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: dataLength,
                      schema: null,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'Variant':
              return parser.readUInt32LE((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: null,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null),
                  ),
                );
              });

            case 'VarChar':
            case 'Char':
            case 'NVarChar':
            case 'NChar':
              return parser.readUInt16LE((dataLength) {
                readCollation(parser, (collation) {
                  callback(
                    Metadata(
                      baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: collation,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null,
                      ),
                    ),
                  );
                });
              });

            case 'Text':
            case 'NText':
              return parser.readUInt32LE((dataLength) {
                readCollation(parser, (collation) {
                  callback(
                    Metadata(
                      baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: collation,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null,
                      ),
                    ),
                  );
                });
              });

            case 'VarBinary':
            case 'Binary':
              return parser.readUInt16LE((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: null,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null),
                  ),
                );
              });

            case 'Image':
              return parser.readUInt32LE((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: dataLength,
                      schema: null,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'Xml':
              return readSchema(parser, (schema) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: null,
                      schema: schema,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'Time':
            case 'DateTime2':
            case 'DateTimeOffset':
              return parser.readUInt8((scale) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: scale,
                      dataLength: null,
                      schema: null,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'NumericN':
            case 'DecimalN':
              return parser.readUInt8((dataLength) {
                parser.readUInt8((precision) {
                  parser.readUInt8((scale) {
                    callback(
                      Metadata(
                        baseMetadata: BaseMetadata(
                          userType: userType,
                          flags: flags,
                          type: type,
                          collation: null,
                          precision: precision,
                          scale: scale,
                          dataLength: dataLength,
                          schema: null,
                          udtInfo: null,
                        ),
                      ),
                    );
                  });
                });
              });

            case 'UDT':
              return readUDTInfo(parser, (udtInfo) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: null,
                        precision: null,
                        scale: null,
                        dataLength: null,
                        schema: null,
                        udtInfo: udtInfo),
                  ),
                );
              });

            default:
              throw MTypeError(sprintf('Unrecognised type %s', type.name));
          }
        });
      });
    });
  } else {
    parser.readUInt32LE((userType) {
      parser.readUInt16LE((flags) {
        parser.readUInt8((typeNumber) {
          DataType? type = DATATYPES[typeNumber];

          if (type == null) {
            throw MTypeError(
                sprintf('Unrecognised data type 0x%02X', typeNumber));
          }

          switch (type.name) {
            case 'Null':
            case 'TinyInt':
            case 'SmallInt':
            case 'Int':
            case 'BigInt':
            case 'Real':
            case 'Float':
            case 'SmallMoney':
            case 'Money':
            case 'Bit':
            case 'SmallDateTime':
            case 'DateTime':
            case 'Date':
              return callback(
                Metadata(
                  baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: null,
                      schema: null,
                      udtInfo: null),
                ),
              );

            case 'IntN':
            case 'FloatN':
            case 'MoneyN':
            case 'BitN':
            case 'UniqueIdentifier':
            case 'DateTimeN':
              return parser.readUInt8((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: dataLength,
                      schema: null,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'Variant':
              return parser.readUInt32LE((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: null,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null),
                  ),
                );
              });

            case 'VarChar':
            case 'Char':
            case 'NVarChar':
            case 'NChar':
              return parser.readUInt16LE((dataLength) {
                readCollation(parser, (collation) {
                  callback(
                    Metadata(
                      baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: collation,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null,
                      ),
                    ),
                  );
                });
              });

            case 'Text':
            case 'NText':
              return parser.readUInt32LE((dataLength) {
                readCollation(parser, (collation) {
                  callback(
                    Metadata(
                      baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: collation,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null,
                      ),
                    ),
                  );
                });
              });

            case 'VarBinary':
            case 'Binary':
              return parser.readUInt16LE((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: null,
                        precision: null,
                        scale: null,
                        dataLength: dataLength,
                        schema: null,
                        udtInfo: null),
                  ),
                );
              });

            case 'Image':
              return parser.readUInt32LE((dataLength) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: dataLength,
                      schema: null,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'Xml':
              return readSchema(parser, (schema) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: null,
                      dataLength: null,
                      schema: schema,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'Time':
            case 'DateTime2':
            case 'DateTimeOffset':
              return parser.readUInt8((scale) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                      userType: userType,
                      flags: flags,
                      type: type,
                      collation: null,
                      precision: null,
                      scale: scale,
                      dataLength: null,
                      schema: null,
                      udtInfo: null,
                    ),
                  ),
                );
              });

            case 'NumericN':
            case 'DecimalN':
              return parser.readUInt8((dataLength) {
                parser.readUInt8((precision) {
                  parser.readUInt8((scale) {
                    callback(
                      Metadata(
                        baseMetadata: BaseMetadata(
                          userType: userType,
                          flags: flags,
                          type: type,
                          collation: null,
                          precision: precision,
                          scale: scale,
                          dataLength: dataLength,
                          schema: null,
                          udtInfo: null,
                        ),
                      ),
                    );
                  });
                });
              });

            case 'UDT':
              return readUDTInfo(parser, (udtInfo) {
                callback(
                  Metadata(
                    baseMetadata: BaseMetadata(
                        userType: userType,
                        flags: flags,
                        type: type,
                        collation: null,
                        precision: null,
                        scale: null,
                        dataLength: null,
                        schema: null,
                        udtInfo: udtInfo),
                  ),
                );
              });

            default:
              throw MTypeError(sprintf('Unrecognised type %s', type.name));
          }
        });
      });
    });
  }
}
