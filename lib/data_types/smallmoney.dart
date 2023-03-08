// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/data_types/moneyn.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final DATA_LENGTH = Buffer.from([0x04]);
final NULL_LENGTH = Buffer.from([0x00]);

class SmallMoney extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'smallmoney';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final buffer = Buffer.alloc(4);
    buffer.writeInt32LE(parameter.value * 10000, 0);
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
    return Buffer.from([MoneyN.refID, 0x04]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x7A;

  static int get refID => 0x7A;

  @override
  String get name => 'SmallMoney';

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
  String get type => 'MONEY4';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }
    value = double.tryParse(value.toString());
    if (isNaN(value)) {
      throw MTypeError('Invalid number.');
    }
    if (value < -214748.3648 || value > 214748.3647) {
      throw MTypeError('Value must be between -214748.3648 and 214748.3647.');
    }
    return value;
  }
}
