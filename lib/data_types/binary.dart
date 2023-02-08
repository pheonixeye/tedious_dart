// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'dart:math' as math;

final NULL_LENGTH = Buffer.from([0xFF, 0xFF]);

class Binary extends DataType {
  static int get refID => 0xAD;

  final int maximumLength;

  Binary({this.maximumLength = 8000});
  @override
  String declaration(Parameter parameter) {
    final value = parameter.value as Buffer?;

    late int length;
    if (parameter.length != null) {
      length = parameter.length!;
    } else if (value != null) {
      length = value.length == 0 ? 1 : value.length;
    } else if (value == null && parameter.output != null) {
      length = 1;
    } else {
      length = this.maximumLength;
    }

    return "binary($length)";
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData<dynamic> parameter, options) async* {
    if (parameter.value == null) {
      return;
    }
    final Buffer val = parameter.value as Buffer;

    yield val.slice(
        0,
        parameter.length != null
            ? math.min(parameter.length!, this.maximumLength)
            : this.maximumLength);
  }

  @override
  Buffer generateParameterLength(ParameterData parameter, options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    final buffer = Buffer.alloc(2);
    buffer.writeUInt16LE(parameter.length!, 0);
    return buffer;
  }

  @override
  Buffer generateTypeInfo(ParameterData parameter, options) {
    final buffer = Buffer.alloc(3);
    buffer.writeUInt8(id, 0);
    buffer.writeUInt16LE(parameter.length!, 1);
    return buffer;
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0xAD;

  @override
  String get name => 'Binary';

  @override
  int? resolveLength(Parameter parameter) {
    final value = parameter.value as Buffer?;

    if (value != null) {
      return value.length;
    } else {
      return this.maximumLength;
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
  String get type => 'BIGBinary';

  @override
  validate(value, collation) {
    throw UnimplementedError();
  }
}
