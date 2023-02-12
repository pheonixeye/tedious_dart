// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/moneyn.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

const SHIFT_LEFT_32 = (1 << 16) * (1 << 16);
const SHIFT_RIGHT_32 = 1 / SHIFT_LEFT_32;

final NULL_LENGTH = Buffer.from([0x00]);
final DATA_LENGTH = Buffer.from([0x08]);

class Money extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'money';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final value = parameter.value * 10000;

    final buffer = Buffer.alloc(8);
    buffer.writeInt32LE(((value as int) * SHIFT_RIGHT_32).floor(), 0);
    buffer.writeInt32LE(value & -1, 4);
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
    return Buffer.from([MoneyN.refID, 0x08]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x3C;

  static int get refID => 0x3C;

  @override
  String get name => 'Money';

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
  String get type => 'MONEY';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }
    value = double.tryParse(value.toString());
    if (isNaN(value)) {
      throw MTypeError('Invalid number.');
    }
    return value;
  }
}
