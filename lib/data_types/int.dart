// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/intn.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final NULL_LENGTH = Buffer.from([0x00]);
final DATA_LENGTH = Buffer.from([0x04]);

class Int extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'int';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final buffer = Buffer.alloc(4);
    buffer.writeInt32LE(int.parse(parameter.value), 0);
    yield buffer;
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    return DATA_LENGTH;
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    return Buffer.from([IntN.refID, 0x04]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x38;

  static int get refID => 0x38;

  @override
  String get name => 'Int';

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
  String get type => 'INT4';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! int) {
      value = int.tryParse(value);
    }

    if (isNaN(value)) {
      throw MTypeError('Invalid number.');
    }

    if (value < -2147483648 || value > 2147483647) {
      throw MTypeError(
          'Value must be between -2147483648 and 2147483647, inclusive.');
    }

    return value | 0;
  }
}
