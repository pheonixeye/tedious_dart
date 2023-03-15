// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/intn.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final DATA_LENGTH = Buffer.from([0x02]);
final NULL_LENGTH = Buffer.from([0x00]);

class SmallInt extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'smallint';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final buffer = Buffer.alloc(2);
    buffer.writeInt16LE(int.tryParse(parameter.value)!, 0);
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
    return Buffer.from([IntN.refID, 0x02]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x34;

  static int get refID => 0x34;

  @override
  String get name => 'SmallInt';

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
  String get type => 'INT2';

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

    if (value < -32768 || value > 32767) {
      throw MTypeError('Value must be between -32768 and 32767, inclusive.');
    }

    return value | 0;
  }
}
