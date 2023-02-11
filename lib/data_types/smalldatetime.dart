// ignore_for_file: non_constant_identifier_names

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/datetimen.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final EPOCH_DATE = DateTime(1900, 0, 1);
final UTC_EPOCH_DATE = DateTime(1900, 0, 1).toUtc();

final DATA_LENGTH = Buffer.from([0x04]);
final NULL_LENGTH = Buffer.from([0x00]);

class SmallDateTime extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'smalldatetime';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final buffer = Buffer.alloc(4);

    int days;
    int dstDiff;
    int minutes;
    if (options.useUTC) {
      days = (((parameter.value as DateTime).millisecondsSinceEpoch -
                  UTC_EPOCH_DATE.millisecondsSinceEpoch) /
              (1000 * 60 * 60 * 24))
          .floor();
      minutes = ((parameter.value as DateTime).toUtc().hour * 60) +
          (parameter.value as DateTime).toUtc().minute;
    } else {
      dstDiff = -((parameter.value as DateTime).timeZoneOffset.inMinutes -
              EPOCH_DATE.timeZoneOffset.inMinutes) *
          60 *
          1000;
      days = (((parameter.value as DateTime).millisecondsSinceEpoch -
                  EPOCH_DATE.millisecondsSinceEpoch +
                  dstDiff) /
              (1000 * 60 * 60 * 24))
          .floor();
      minutes = ((parameter.value as DateTime).toLocal().hour * 60) +
          (parameter.value as DateTime).toLocal().minute;
    }

    buffer.writeUInt16LE(days, 0);
    buffer.writeUInt16LE(minutes, 2);

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
    return Buffer.from([DateTimeN.refID, 0x04]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x3A;

  static int get refID => 0x3A;

  @override
  String get name => 'SmallDateTime';

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
  String get type => 'DATETIM4';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if ((value is! DateTime)) {
      value = DateTime.tryParse(value.toString());
    }

    if (isNaN(value)) {
      throw MTypeError('Invalid date.');
    }

    return value;
  }
}
