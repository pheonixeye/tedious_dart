// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/intn.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final DATA_LENGTH = Buffer.from([0x01]);
final NULL_LENGTH = Buffer.from([0x00]);

class TinyInt extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'tinyint';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final buffer = Buffer.alloc(1);
    buffer.writeUInt8(int.tryParse(parameter.value)!, 0);
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
    return Buffer.from([IntN.refID, 0x01]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x30;

  static int get refID => 0x30;

  @override
  String get name => 'TinyInt';

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
  String get type => 'INT1';

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

    if (value < 0 || value > 255) {
      throw MTypeError('Value must be between 0 and 255, inclusive.');
    }

    return value | 0;
  }
}
