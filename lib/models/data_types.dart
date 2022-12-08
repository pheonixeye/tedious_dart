import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/models/buffer.dart';

class Parameter {
  late DataType type;
  late String name;

  dynamic value;

  late bool output;
  int? length;
  num? precision;
  num? scale;

  bool? nullable;

  bool? forceEncrypt;
  CryptoMetadata? cryptoMetadata;
  Buffer? encryptedVal;
}

class ParameterData<T> {
  int? length;
  num? scale;
  num? precision;

  Collation? collation;

  T? value;
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
