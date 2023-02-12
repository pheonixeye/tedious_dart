import 'dart:math';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/decimaln.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';
// ignore: unused_import
import 'package:tedious_dart/extensions/is_nan_on_dynamic.dart';

// ignore: non_constant_identifier_names
final NULL_LENGTH = Buffer.from([0x00]);

class Decimal extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'decimal(${resolvePrecision(parameter)}, ${resolveScale(parameter)})';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final sign = parameter.value < 0 ? 0 : 1;
    final value =
        (((parameter.value as int) * pow(10, parameter.scale!)).abs()).round();
    final precision = parameter.precision!;
    if (precision <= 9) {
      final buffer = Buffer.alloc(5);
      buffer.writeUInt8(sign, 0);
      buffer.writeUInt32LE(value, 1);
      yield buffer;
    } else if (precision <= 19) {
      final buffer = WritableTrackingBuffer(initialSize: 9);
      buffer.writeUInt8(sign);
      buffer.writeUInt64LE(value);
      yield buffer.data!;
    } else if (precision <= 28) {
      final buffer = WritableTrackingBuffer(initialSize: 13);
      buffer.writeUInt8(sign);
      buffer.writeUInt64LE(value);
      buffer.writeUInt32LE(0x00000000);
      yield buffer.data!;
    } else {
      final buffer = WritableTrackingBuffer(initialSize: 17);
      buffer.writeUInt8(sign);
      buffer.writeUInt64LE(value);
      buffer.writeUInt32LE(0x00000000);
      buffer.writeUInt32LE(0x00000000);
      yield buffer.data!;
    }
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    final precision = parameter.precision!;
    if (precision <= 9) {
      return Buffer.from([0x05]);
    } else if (precision <= 19) {
      return Buffer.from([0x09]);
    } else if (precision <= 28) {
      return Buffer.from([0x0D]);
    } else {
      return Buffer.from([0x11]);
    }
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    int precision;
    if (parameter.precision! <= 9) {
      precision = 0x05;
    } else if (parameter.precision! <= 19) {
      precision = 0x09;
    } else if (parameter.precision! <= 28) {
      precision = 0x0D;
    } else {
      precision = 0x11;
    }

    return Buffer.from(
        [DecimalN.refID, precision, parameter.precision!, parameter.scale!]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x37;

  static int get refID => 0x37;

  @override
  String get name => 'Decimal';

  @override
  int? resolveLength(Parameter parameter) {
    throw UnimplementedError();
  }

  @override
  num? resolvePrecision(Parameter parameter) {
    if (parameter.precision != null) {
      return parameter.precision;
    } else if (parameter.value == null) {
      return 1;
    } else {
      return 18;
    }
  }

  @override
  num? resolveScale(Parameter parameter) {
    if (parameter.scale != null) {
      return parameter.scale;
    } else {
      return 0;
    }
  }

  @override
  String get type => 'DECIMAL';

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
