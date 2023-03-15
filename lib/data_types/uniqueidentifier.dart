// ignore_for_file: non_constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/guid_parser.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final NULL_LENGTH = Buffer.from([0x00]);
final DATA_LENGTH = Buffer.from([0x10]);

class UniqueIdentifier extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'uniqueidentifier';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    yield Buffer.from(guidToArray(parameter.value));
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
    return Buffer.from([id, 0x10]);
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x24;

  static int get refID => 0x24;

  @override
  String get name => 'UniqueIdentifier';

  @override
  int? resolveLength(Parameter parameter) {
    return 16;
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
  String get type => 'GUIDN';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw MTypeError('Invalid string.');
    }

    if (!RegExp(
            r'!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i')
        .hasMatch(value)) {
      throw MTypeError('Invalid GUID.');
    }

    return value;
  }
}
