// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final NULL_LENGTH = Buffer.from([0xFF, 0xFF, 0xFF, 0xFF]);

class NText extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'ntext';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }
    yield Buffer.from(parameter.value.toString(), 0, 0, 'ucs2');
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    final buffer = Buffer.alloc(4);
    buffer.writeInt32LE(Buffer.byteLength(parameter.value, 'ucs2'), 0);
    return buffer;
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    final buffer = Buffer.alloc(10);
    buffer.writeUInt8(id, 0);
    buffer.writeInt32LE(parameter.length!, 1);

    if (parameter.collation != null) {
      parameter.collation!.toBuffer().copy(buffer, 5, 0, 5);
    }

    return buffer;
  }

  @override
  bool? get hasTableName => false;

  @override
  int get id => 0x63;

  static int get refID => 0x63;

  @override
  String get name => 'NText';

  @override
  int? resolveLength(Parameter parameter) {
    final value =
        parameter.value; // Temporary solution. Remove 'dynamic' later.
    if (value != null) {
      return value.length;
    } else {
      return -1;
    }
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
  String get type => 'NTEXT';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw MTypeError('Invalid string.');
    }

    return value;
  }
}
