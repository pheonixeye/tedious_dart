// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';
import 'package:tedious_dart/value_parser.dart';

// ignore: unused_import
import 'package:tedious_dart/extensions/is_nan_on_dynamic.dart';

final EPOCH_DATE = DateTime(1, 1).toLocal(); // LocalDate.ofYearDay(1, 1);
final NULL_LENGTH = Buffer.from([0x00]);

class DateTimeOffset extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'datetimeoffset(${resolveScale(parameter)})';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final value = parameter.value as DateWithNanosecondsDelta;
    var scale = parameter.scale;

    final buffer = WritableTrackingBuffer(initialSize: 16);
    scale = scale!;

    int timestamp;
    timestamp = ((value.toUtc().hour * 60 + value.toUtc().minute) * 60 +
                value.toUtc().second) *
            1000 +
        value.toUtc().millisecond;
    timestamp = timestamp * pow(10, scale - 3) as int;
    timestamp += (value.nanosecondsDelta ?? 0) * pow(10, scale) as int;
    timestamp = timestamp.round();

    switch (scale) {
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

    final date = DateTime.utc(value.year, value.month + 1, value.day).toLocal();

    final days = EPOCH_DATE.difference(date).inDays;
    buffer.writeUInt24LE(days);

    final offset = -value.timeZoneOffset;
    buffer.writeInt16LE(offset.inMinutes);
    yield buffer.data!;
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
        return Buffer.from([0x08]);

      case 3:
      case 4:
        return Buffer.from([0x09]);

      case 5:
      case 6:
      case 7:
        return Buffer.from([0x0A]);

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
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x2B;

  static int get refID => 0x2B;

  @override
  String get name => 'DateTimeOffset';

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
    if (parameter.scale != null) {
      return parameter.scale;
    } else if (parameter.value == null) {
      return 0;
    } else {
      return 7;
    }
  }

  @override
  String get type => 'DATETIMEOFFSETN';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! DateTime) {
      value = DateTime.tryParse(value);
    }

    if (isNaN(value)) {
      throw MTypeError('Invalid date.');
    }

    return value;
  }
}
