// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final NULL_LENGTH = Buffer.from([0xFF, 0xFF, 0xFF, 0xFF]);

class Text extends DataType {
  @override
  String declaration(Parameter parameter) {
    return 'text';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    final value = parameter.value as Buffer?;

    if (value == null) {
      return;
    }

    yield value;
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    final value = parameter.value as Buffer?;

    if (value == null) {
      return NULL_LENGTH;
    }

    final buffer = Buffer.alloc(4);
    buffer.writeInt32LE(value.length, 0);
    return buffer;
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    final buffer = Buffer.alloc(10);
    buffer.writeUInt8(id, 0);
    buffer.writeInt32LE(parameter.length!, 1);

    if (parameter.collation != null) {
      parameter.collation!.toBuffer().copy(buffer, 5, 0, 5);
    }

    return buffer;
  }

  @override
  // TODO: implement hasTableName
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0x23;

  static int get refID => 0x23;

  @override
  String get name => 'Text';

  @override
  int? resolveLength(Parameter parameter) {
    final value = parameter.value as Buffer?;

    if (value != null) {
      return value.length;
    } else {
      return -1;
    }
  }

  @override
  num? resolvePrecision(Parameter parameter) {
    // TODO: implement resolvePrecision
    throw UnimplementedError();
  }

  @override
  num? resolveScale(Parameter parameter) {
    // TODO: implement resolveScale
    throw UnimplementedError();
  }

  @override
  String get type => 'TEXT';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw MTypeError('Invalid string.');
    }

    if (collation == null) {
      throw MTypeError(
          'No collation was set by the server for the current connection.');
    }

    if (collation.codepage == null) {
      throw MTypeError(
          'The collation set by the server has no associated encoding.');
    }

    //TODO: check implementation
    var res = Buffer.from(utf8.encode(value));

    // return iconv.encode(value, collation.codepage);

    return res;
  }
}
