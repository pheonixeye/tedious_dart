import 'dart:math';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';
import 'package:tedious_dart/value_parser.dart';

// ignore: non_constant_identifier_names
final NULL_LENGTH = Buffer.from([0x00]);

class Time extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'time(' '${(resolveScale(parameter))}' ')';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final buffer = WritableTrackingBuffer(initialSize: 16);
    final time = parameter.value as DateWithNanosecondsDelta;

    int timestamp;
    if (options.useUTC) {
      timestamp = ((time.toUtc().hour * 60 + time.toUtc().minute) * 60 +
                  time.toUtc().second) *
              1000 +
          time.toUtc().millisecond;
    } else {
      timestamp = ((time.hour * 60 + time.minute) * 60 + time.second) * 1000 +
          time.millisecond;
    }

    timestamp = timestamp * pow(10, parameter.scale! - 3) as int;
    timestamp +=
        (time.nanosecondsDelta ?? 0) * pow(10, parameter.scale!) as int;
    timestamp = timestamp.round();

    switch (parameter.scale!.toDouble()) {
      case 0:
      case 1:
      case 2:
        buffer.writeUInt24LE(timestamp);
        break;
      case 3:
      case 4:
        buffer.writeUInt32LE(timestamp);
        break;
      case 5:
      case 6:
      case 7:
        buffer.writeUInt40LE(timestamp);
    }

    yield buffer.data;
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    switch (parameter.scale) {
      case 0:
      case 1:
      case 2:
        return Buffer.from([0x03]);
      case 3:
      case 4:
        return Buffer.from([0x04]);
      case 5:
      case 6:
      case 7:
        return Buffer.from([0x05]);
      default:
        throw MTypeError('invalid scale');
    }
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    return Buffer.from([id, parameter.scale!]);
  }

  @override
  // TODO: implement hasTableName
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x29;

  static int get refID => 0x29;

  @override
  String get name => 'Time';

  @override
  int? resolveLength(Parameter parameter) {
    // TODO: implement resolveLength
    throw UnimplementedError();
  }

  @override
  num? resolvePrecision(Parameter parameter) {
    // TODO: implement resolvePrecision
    throw UnimplementedError();
  }

  @override
  num? resolveScale(Parameter parameter) {
    if (parameter.scale != null) {
      return parameter.scale;
    } else if (parameter.value == null) {
      return 0;
    } else {
      return 7;
    }
  }

  @override
  String get type => 'TIMEN';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if ((value is! DateTime)) {
      value = DateTime.tryParse(value.toString());
    }

    if (isNaN(value)) {
      throw MTypeError('Invalid time.');
    }

    return value;
  }
}
