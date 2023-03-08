// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/data_types/binary.dart';
import 'package:tedious_dart/data_types/bit.dart';
import 'package:tedious_dart/data_types/bitn.dart';
import 'package:tedious_dart/data_types/char.dart';
import 'package:tedious_dart/data_types/date.dart';
import 'package:tedious_dart/data_types/dateTime.dart' as d;
import 'package:tedious_dart/data_types/bigint.dart';
import 'package:tedious_dart/data_types/datetime2.dart';
import 'package:tedious_dart/data_types/datetimen.dart';
import 'package:tedious_dart/data_types/datetimeoffset.dart';
import 'package:tedious_dart/data_types/decimal.dart';
import 'package:tedious_dart/data_types/decimaln.dart';
import 'package:tedious_dart/data_types/float.dart';
import 'package:tedious_dart/data_types/floatn.dart';
import 'package:tedious_dart/data_types/image.dart';
import 'package:tedious_dart/data_types/int.dart';
import 'package:tedious_dart/data_types/intn.dart';
import 'package:tedious_dart/data_types/money.dart';
import 'package:tedious_dart/data_types/moneyn.dart';
import 'package:tedious_dart/data_types/nchar.dart';
import 'package:tedious_dart/data_types/ntext.dart';
import 'package:tedious_dart/data_types/numeric.dart';
import 'package:tedious_dart/data_types/numericn.dart';
import 'package:tedious_dart/data_types/nvarchar.dart';
import 'package:tedious_dart/data_types/real.dart';
import 'package:tedious_dart/data_types/smalldatetime.dart';
import 'package:tedious_dart/data_types/smallint.dart';
import 'package:tedious_dart/data_types/smallmoney.dart';
import 'package:tedious_dart/data_types/sql_variant.dart';
import 'package:tedious_dart/data_types/text.dart';
import 'package:tedious_dart/data_types/time.dart';
import 'package:tedious_dart/data_types/tinyint.dart';
import 'package:tedious_dart/data_types/null.dart' as n;
import 'package:tedious_dart/data_types/tvp.dart';
import 'package:tedious_dart/data_types/udt.dart';
import 'package:tedious_dart/data_types/uniqueidentifier.dart';
import 'package:tedious_dart/data_types/varbinary.dart';
import 'package:tedious_dart/data_types/varchar.dart';
import 'package:tedious_dart/data_types/xml.dart';

class Parameter {
  DataType? type;
  String? name;

  dynamic value;

  bool? output;
  int? length;
  num? precision;
  num? scale;

  bool? nullable;

  bool? forceEncrypt;
  CryptoMetadata? cryptoMetadata;
  Buffer? encryptedVal;

  Parameter(
      {this.cryptoMetadata,
      this.encryptedVal,
      this.forceEncrypt,
      this.length,
      this.name,
      this.nullable,
      this.output,
      this.precision,
      this.scale,
      this.type,
      this.value});

  factory Parameter.copyWith({
    DataType? type,
    String? name,
    dynamic value,
    bool? output,
    int? length,
    num? precision,
    num? scale,
    bool? nullable,
    bool? forceEncrypt,
    CryptoMetadata? cryptoMetadata,
    Buffer? encryptedVal,
  }) {
    return Parameter()
      ..type = type
      ..cryptoMetadata = cryptoMetadata
      ..encryptedVal = encryptedVal
      ..forceEncrypt = forceEncrypt
      ..length = length
      ..name = name
      ..nullable = nullable
      ..output = output
      ..precision = precision
      ..scale = scale
      ..value = value;
  }
}

class ParameterData<T> {
  int? length;
  num? scale;
  num? precision;

  Collation? collation;

  T? value;

  ParameterData({
    this.collation,
    this.length,
    this.precision,
    this.scale,
    this.value,
  });
}

abstract class DataType {
  int get id;
  String get type;
  String get name;

  String declaration(Parameter parameter);

  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options);

  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options);

  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options);

  dynamic validate(dynamic value, Collation? collation);

  bool? get hasTableName;

  int? resolveLength(Parameter parameter);
  num? resolvePrecision(Parameter parameter);
  num? resolveScale(Parameter parameter);
}

final Map<int, DataType> DATATYPES = {
  n.Null.refID: n.Null(),
  TinyInt.refID: TinyInt(),
  Bit.refID: Bit(),
  SmallInt.refID: SmallInt(),
  Int.refID: Int(),
  SmallDateTime.refID: SmallDateTime(),
  Real.refID: Real(),
  Money.refID: Money(),
  d.DateTime.refID: d.DateTime(),
  Float.refID: Float(),
  Decimal.refID: Decimal(),
  Numeric.refID: Numeric(),
  SmallMoney.refID: SmallMoney(),
  BigInt.refID: BigInt(),
  Image.refID: Image(),
  Text.refID: Text(),
  UniqueIdentifier.refID: UniqueIdentifier(),
  IntN.refID: IntN(),
  NText.refID: NText(),
  BitN.refID: BitN(),
  DecimalN.refID: DecimalN(),
  NumericN.refID: NumericN(),
  FloatN.refID: FloatN(),
  MoneyN.refID: MoneyN(),
  DateTimeN.refID: DateTimeN(),
  VarBinary.refID: VarBinary(),
  VarChar.refID: VarChar(),
  Binary.refID: Binary(),
  Char.refID: Char(),
  NVarChar.refID: NVarChar(),
  NChar.refID: NChar(),
  Xml.refID: Xml(),
  Time.refID: Time(),
  Date.refID: Date(),
  DateTime2.refID: DateTime2(),
  DateTimeOffset.refID: DateTimeOffset(),
  UDT.refID: UDT(),
  TVP.refID: TVP(),
  Variant.refID: Variant(),
};

bool isNaN(dynamic value) =>
    (value is int || value is double || value is num) ? false : true;
