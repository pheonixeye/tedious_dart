// ignore_for_file: non_constant_identifier_names

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/bitn.dart';
import 'package:tedious_dart/models/data_types.dart';

final DATA_LENGTH = Buffer.alloc(0x01);
final NULL_LENGTH = Buffer.alloc(0x00);

class Bit extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'bit';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, options) async* {
    if (parameter.value == null) {
      return;
    }

    yield parameter.value ? Buffer.from(0x01) : Buffer.from(0x00);
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
    return Buffer.from([BitN.getId, 0x01]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  static int get id => 0x32;

  @override
  String get name => 'Bit';

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
  String get type => 'BIT';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }
    if (value) {
      return true;
    } else {
      return false;
    }
  }
}
