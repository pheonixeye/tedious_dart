// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/src/tracking_buffer/writable_tracking_buffer.dart';

final DATA_LENGTH = Buffer.alloc(0x08);
final NULL_LENGTH = Buffer.alloc(0x00);

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
    buffer.writeInt64LE(Number(parameter.value));
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
    return Buffer.from([IntN.id, 0x08]);
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

    if (value.runtimeType != num) {
      value = Number(value);
    }

    if (value.isNaN()) {
      throw MTypeError('Invalid number.');
    }

    if (value < Number.MIN_SAFE_INTEGER || value > Number.MAX_SAFE_INTEGER) {
      throw MTypeError(
          'Value must be between ${Number.MIN_SAFE_INTEGER} and ${Number.MAX_SAFE_INTEGER}, inclusive.  For smaller or bigger numbers, use VarChar type.');
    }

    return value;
  }
}

extension IsNaN on dynamic {
  bool isNaN() {
    try {
      this is num;
      return true;
    } catch (e) {
      return false;
    }
  }
}
