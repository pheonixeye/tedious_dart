import 'package:tedious_dart/models/buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';

class BitN extends DataType {
  @override
  String declaration(Parameter parameter) {
    // TODO: implement declaration
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> generateParameterData(ParameterData parameter, options) {
    // TODO: implement generateParameterData
    throw UnimplementedError();
  }

  @override
  Buffer generateParameterLength(ParameterData parameter, options) {
    // TODO: implement generateParameterLength
    throw UnimplementedError();
  }

  @override
  Buffer generateTypeInfo(ParameterData parameter, options) {
    // TODO: implement generateTypeInfo
    throw UnimplementedError();
  }

  @override
  // TODO: implement hasTableName
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
