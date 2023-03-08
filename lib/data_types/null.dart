import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';

class Null extends DataType {
  @override
  String declaration(Parameter parameter) {
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) {
    throw UnimplementedError();
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    throw UnimplementedError();
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    throw UnimplementedError();
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x1F;

  static int get refID => 0x1F;

  @override
  String get name => 'Null';

  @override
  int? resolveLength(Parameter parameter) {
    throw UnimplementedError();
  }

  @override
  num? resolvePrecision(Parameter parameter) {
    throw UnimplementedError();
  }

  @override
  num? resolveScale(Parameter parameter) {
    throw UnimplementedError();
  }

  @override
  String get type => 'NULL';

  @override
  validate(value, Collation? collation) {
    throw UnimplementedError();
  }
}
