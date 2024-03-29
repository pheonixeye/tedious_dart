import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/models/data_types.dart';

class Xml extends DataType {
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
  int get id => 0xF1;

  static int get refID => 0xF1;

  @override
  String get name => 'Xml';

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
  String get type => 'XML';

  @override
  validate(value, Collation? collation) {
    throw UnimplementedError();
  }
}
