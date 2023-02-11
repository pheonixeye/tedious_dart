import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/collation.dart';
import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/models/data_types.dart';

class Variant extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'sql_variant';
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
  int get id => 0x62;

  static int get refID => 0x62;

  @override
  String get name => 'Variant';

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
  String get type => 'SSVARIANTTYPE';

  @override
  validate(value, Collation? collation) {
    throw UnimplementedError();
  }
}
