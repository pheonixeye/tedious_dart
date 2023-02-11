import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/floatn.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

// ignore: non_constant_identifier_names
final NULL_LENGTH = Buffer.from([0x00]);

class Float extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'float';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final buffer = Buffer.alloc(8);
    buffer.writeDoubleLE(double.parse(parameter.value), 0);
    yield buffer;
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    return Buffer.from([0x08]);
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    return Buffer.from([FloatN.refID, 0x08]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x3E;

  static int get refID => 0x3E;

  @override
  String get name => 'Float';

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
  String get type => 'FLT8';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }
    value = double.parse(value);
    if (isNaN(value)) {
      throw MTypeError('Invalid number.');
    }
    return value;
  }
}
