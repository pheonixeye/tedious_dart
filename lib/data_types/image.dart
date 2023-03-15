// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final NULL_LENGTH = Buffer.from([0xFF, 0xFF, 0xFF, 0xFF]);

class Image extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'image';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }
    yield parameter.value as Buffer;
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    final buffer = Buffer.alloc(4);
    buffer.writeInt32LE(parameter.value.length!, 0);
    return buffer;
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    final buffer = Buffer.alloc(5);
    buffer.writeUInt8(id, 0);
    buffer.writeInt32LE(parameter.length!, 1);
    return buffer;
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x22;

  static int get refID => 0x22;

  @override
  String get name => 'Image';

  @override
  int? resolveLength(Parameter parameter) {
    if (parameter.value != null) {
      final value = parameter
          .value; // TODO: Temporary solution. Replace 'dynamic' more with specific type;
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
  String get type => 'IMAGE';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }
    if (!Buffer.isBuffer(value)) {
      throw MTypeError('Invalid buffer.');
    }
    return value;
  }
}
