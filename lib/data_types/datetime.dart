// ignore_for_file: non_constant_identifier_names

import 'dart:core';
import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/data_types/date.dart';
import 'package:tedious_dart/data_types/datetimen.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'dart:core' as core show DateTime;

import 'package:tedious_dart/models/errors.dart';

final EPOCH_DATE = core.DateTime(1900, 1).toLocal();
// LocalDate.ofYearDay(1900, 1);
final NULL_LENGTH = Buffer.from([0x00]);
final DATA_LENGTH = Buffer.from([0x08]);

class DateTime extends DataType {
  @override
  int get id => 0x3D;

  static int get refID => 0x3D;

  @override
  String declaration(Parameter parameter) {
    return 'datetime';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final value = parameter.value as core.DateTime;
    // Temporary solution. Remove 'any' later.

    core.DateTime date;
    if (options.useUTC) {
      date =
          core.DateTime.utc(value.year, value.month + 1, value.day).toLocal();
      // LocalDate.of(
      //     value.getUTCFullYear(), value.getUTCMonth() + 1, value.getUTCDate());
    } else {
      date = core.DateTime(value.year, value.month + 1, value.day).toLocal();
    }

    int days = EPOCH_DATE.difference(date).inDays;

    int milliseconds;
    int threeHundredthsOfSecond;
    if (options.useUTC) {
      var seconds = value.toUtc().hour * 60 * 60;
      seconds += value.toUtc().minute * 60;
      seconds += value.toUtc().second;
      milliseconds = (seconds * 1000) + value.toUtc().millisecond;
    } else {
      var seconds = value.hour * 60 * 60;
      seconds += value.minute * 60;
      seconds += value.second;
      milliseconds = (seconds * 1000) + value.millisecond;
    }

    threeHundredthsOfSecond = milliseconds ~/ (3 + (1 / 3));
    threeHundredthsOfSecond = (threeHundredthsOfSecond).round();

    // 25920000 equals one day
    if (threeHundredthsOfSecond == 25920000) {
      days += 1;
      threeHundredthsOfSecond = 0;
    }

    final buffer = Buffer.alloc(8);
    buffer.writeInt32LE(days, 0);
    buffer.writeUInt32LE(threeHundredthsOfSecond, 4);
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
    return Buffer.from([DateTimeN.refID, 0x08]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  String get name => 'DateTime';

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
  String get type => 'DATETIME';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! Date) {
      value = core.DateTime.tryParse(value);
    }

    if (isNaN(value)) {
      throw MTypeError('Invalid date.');
    }

    return value;
  }
}
