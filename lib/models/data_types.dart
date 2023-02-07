// ignore_for_file: non_constant_identifier_names

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/data_types/bit.dart';
import 'package:tedious_dart/data_types/bitn.dart';
import 'package:tedious_dart/data_types/char.dart';
import 'package:tedious_dart/data_types/date.dart';
import 'package:tedious_dart/data_types/bigint.dart';

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
}

class ParameterData<T> {
  int? length;
  num? scale;
  num? precision;

  Collation? collation;

  T? value;
}

abstract class DataType {
  static int get id => 0;
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

final Map<int, dynamic> TYPE = {
  Null.id: Null,
  TinyInt.id: TinyInt,
  Bit.id: Bit,
  SmallInt.id: SmallInt,
  Int.id: Int,
  SmallDateTime.id: SmallDateTime,
  Real.id: Real,
  Money.id: Money,
  DateTime.id: DateTime,
  Float.id: Float,
  Decimal.id: Decimal,
  Numeric.id: Numeric,
  SmallMoney.id: SmallMoney,
  BigInt.id: BigInt,
  Image.id: Image,
  Text.id: Text,
  UniqueIdentifier.id: UniqueIdentifier,
  IntN.id: IntN,
  NText.id: NText,
  BitN.id: BitN,
  DecimalN.id: DecimalN,
  NumericN.id: NumericN,
  FloatN.id: FloatN,
  MoneyN.id: MoneyN,
  DateTimeN.id: DateTimeN,
  VarBinary.id: VarBinary,
  VarChar.id: VarChar,
  Binary.id: Binary,
  Char.id: Char,
  NVarChar.id: NVarChar,
  NChar.id: NChar,
  Xml.id: Xml,
  Time.id: Time,
  Date.id: Date,
  DateTime2.id: DateTime2,
  DateTimeOffset.id: DateTimeOffset,
  UDT.id: UDT,
  TVP.id: TVP,
  Variant.id: Variant,
};
