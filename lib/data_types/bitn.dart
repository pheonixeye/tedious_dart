import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';

class BitN extends DataType {
  static int get refID => 0x68;

  @override
  String declaration(Parameter parameter) {
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, options) async* {
    throw UnimplementedError();
  }

  @override
  Buffer generateParameterLength(ParameterData parameter, options) {
    throw UnimplementedError();
  }

  @override
  Buffer generateTypeInfo(ParameterData parameter, options) {
    throw UnimplementedError();
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x68;

  @override
  String get name => 'BitN';

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
  String get type => 'BITN';

  @override
  validate(value, Collation? collation) {
    throw UnimplementedError();
  }
}
