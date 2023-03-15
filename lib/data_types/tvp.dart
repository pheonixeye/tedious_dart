// ignore_for_file: non_finalant_identifier_names, non_constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';

final TVP_ROW_TOKEN = Buffer.from([0x01]);
final TVP_END_TOKEN = Buffer.from([0x00]);

final NULL_LENGTH = Buffer.from([0xFF, 0xFF]);

class TVP extends DataType {
  @override
  String declaration(Parameter parameter) {
    final value = parameter.value; // Temporary solution. Remove 'any' later.
    return value.name + ' readonly';
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      yield TVP_END_TOKEN;
      yield TVP_END_TOKEN;
      return;
    }

    // const { columns, rows } = parameter.value;
    final rows = parameter.value.rows;
    final columns = parameter.value.columns;

    for (int i = 0, len = columns.length; i < len; i++) {
      final column = columns[i];

      final buff = Buffer.alloc(6);
      // UserType
      buff.writeUInt32LE(0x00000000, 0);

      // Flags
      buff.writeUInt16LE(0x0000, 4);
      yield buff;

      // TYPE_INFO
      yield column.type.generateTypeInfo(column) as Buffer;

      // ColName
      yield Buffer.from([0x00]);
    }

    yield TVP_END_TOKEN;

    for (int i = 0, length = rows.length; i < length; i++) {
      yield TVP_ROW_TOKEN;

      var row = rows[i];
      for (int k = 0, len2 = row.length; k < len2; k++) {
        final column = columns[k];
        final value = row[k];

        final param = ParameterData(
            value: column.type.validate(value, parameter.collation),
            length: column.length,
            scale: column.scale,
            precision: column.precision);

        // TvpColumnData
        yield column.type.generateParameterLength(param, options) as Buffer;
        yield* column.type.generateParameterData(param, options);
      }
    }

    yield TVP_END_TOKEN;
  }
  //TODO: unknown data types??

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    final columns = parameter.value;
    final buffer = Buffer.alloc(2);
    buffer.writeUInt16LE(columns.length, 0);
    return buffer;
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    final databaseName = '';
    final schema = parameter.value?.schema ?? '';
    final typeName = parameter.value?.name ?? '';

    var bufferLength = 1 +
        1 +
        Buffer.byteLength(databaseName, 'ucs2') +
        1 +
        Buffer.byteLength(schema, 'ucs2') +
        1 +
        Buffer.byteLength(typeName, 'ucs2');

    final buffer =
        WritableTrackingBuffer(initialSize: bufferLength, encoding: 'ucs2');
    buffer.writeUInt8(id);
    buffer.writeBVarchar(databaseName, 'ucs2');
    buffer.writeBVarchar(schema, 'ucs2');
    buffer.writeBVarchar(typeName, 'ucs2');

    return buffer.data!;
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0xF3;

  static int get refID => 0xF3;

  @override
  String get name => 'TVP';

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
  String get type => 'TVPTYPE';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! dynamic) {
      //TODO:object ,instead of dynamic, of typescript?? needed??
      throw MTypeError('Invalid table.');
    }

    if (value.columns is! List) {
      throw MTypeError('Invalid table.');
    }

    if (value.rows is! List) {
      throw MTypeError('Invalid table.');
    }

    return value;
  }
}
