// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';

late final DateTime? globalDate;
final EPOCH_DATE = DateTime(1, 1, 1).toLocal();
final NULL_LENGTH = Buffer.alloc(0x00);
final DATA_LENGTH = Buffer.alloc(0x03);

class Date extends DataType {
  static int get refID => 0x28;

  @override
  String declaration(Parameter parameter) {
    return 'date';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, options) async* {
    if (parameter.value == null) {
      return;
    }

    final value =
        parameter.value as DateTime; // Temporary solution. Remove 'any' later.

    DateTime date;
    if (options.useUTC) {
      date = DateTime(value.year, value.month + 1, value.day).toUtc().toLocal();
    } else {
      date = DateTime(value.year, value.month + 1, value.day).toLocal();
    }

    var days = EPOCH_DATE.difference(date);
    var buffer = Buffer.alloc(3);
    buffer.writeUIntLE(days.inDays, 0, 3);
    yield buffer;
  }

  @override
  Buffer generateParameterLength(ParameterData parameter, options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    return DATA_LENGTH;
  }

  @override
  Buffer generateTypeInfo(ParameterData parameter, options) {
    return Buffer.alloc(id);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x28;

  @override
  String get name => 'Date';

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
  String get type => 'DATEN';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! DateTime) {
      value = DateTime.parse(value);
    }

    if (isNaN(value)) {
      throw ArgumentError('Invalid date.');
    }

    return value;
  }
}
