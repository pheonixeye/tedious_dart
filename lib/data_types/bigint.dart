// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:math';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/data_types/intn.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';

final DATA_LENGTH = Buffer.alloc(0x08);
final NULL_LENGTH = Buffer.alloc(0x00);
// const MAX_SAFE_INTEGER = 9007199254740991;
final MAX_SAFE_INTEGER = pow(2, 53) - 1;
final MIN_SAFE_INTEGER = -(pow(2, 53) - 1);
// 2^53 − 1;

class BigInt extends DataType {
  static int get refID => 0x7f;

  @override
  String declaration(Parameter parameter) {
    return 'bigint';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, options) async* {
    if (parameter.value == null) {
      return;
    }

    var buffer = WritableTrackingBuffer(initialSize: 8);
    buffer.writeInt64LE(int.tryParse(parameter.value)!);
    yield buffer.data!;
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
    return Buffer.from([IntN.refID, 0x08]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x7f;

  @override
  String get name => 'BigInt';

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
  String get type => 'INT8';

  @override
  validate(value, collation) {
    if (value == null) {
      return null;
    }

    if (value is! num) {
      value = num.tryParse(value);
    }

    if (isNaN(value)) {
      throw MTypeError('Invalid number.');
    }

    if (value < MIN_SAFE_INTEGER || value > MAX_SAFE_INTEGER) {
      throw MTypeError(
          'Value must be between $MIN_SAFE_INTEGER and $MAX_SAFE_INTEGER, inclusive.  For smaller or bigger numbers, use VarChar type.');
    }

    return value;
  }
}
