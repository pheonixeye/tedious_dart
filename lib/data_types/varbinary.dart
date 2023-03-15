// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

const MAX = (1 << 16) - 1;
final UNKNOWN_PLP_LEN =
    Buffer.from([0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
final PLP_TERMINATOR = Buffer.from([0x00, 0x00, 0x00, 0x00]);

final NULL_LENGTH = Buffer.from([0xFF, 0xFF]);
final MAX_NULL_LENGTH =
    Buffer.from([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);

class VarBinary extends DataType {
  final int maximumLength;
  VarBinary({this.maximumLength = 8000});
  @override
  String declaration(Parameter parameter) {
    final value = parameter.value; // Temporary solution. Remove 'any' later.
    int length;
    if (parameter.length != null) {
      length = parameter.length!;
    } else if (value != null) {
      length = value.length == 0 ? 1 : value.length;
    } else if (value == null && !parameter.output!) {
      length = 1;
    } else {
      length = maximumLength;
    }

    if (length <= maximumLength) {
      return 'varbinary(' '$length' ')';
    } else {
      return 'varbinary(max)';
    }
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    var value = parameter.value;

    if (parameter.length! <= maximumLength) {
      if (Buffer.isBuffer(value)) {
        yield value as Buffer;
      } else {
        yield Buffer.from(value.toString(), 0, 0, 'ucs2');
      }
    } else {
      // writePLPBody
      if (!Buffer.isBuffer(value)) {
        value = value.toString();
      }

      final length = Buffer.byteLength(value, 'ucs2');

      if (length > 0) {
        final buffer = Buffer.alloc(4);
        buffer.writeUInt32LE(length, 0);
        yield buffer;

        if (Buffer.isBuffer(value)) {
          yield value as Buffer;
        } else {
          yield Buffer.from(value, 0, 0, 'ucs2');
        }
      }

      yield PLP_TERMINATOR;
    }
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      if (parameter.length! <= maximumLength) {
        return NULL_LENGTH;
      } else {
        return MAX_NULL_LENGTH;
      }
    }

    dynamic value = parameter.value;
    if (!Buffer.isBuffer(value)) {
      value = value.toString();
    }

    final length = Buffer.byteLength(value, 'ucs2');

    if (parameter.length! <= maximumLength) {
      final buffer = Buffer.alloc(2);
      buffer.writeUInt16LE(length, 0);
      return buffer;
    } else {
      // writePLPBody
      return UNKNOWN_PLP_LEN;
    }
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    final buffer = Buffer.alloc(3);
    buffer.writeUInt8(id, 0);

    if (parameter.length! <= maximumLength) {
      buffer.writeUInt16LE(parameter.length!, 1);
    } else {
      buffer.writeUInt16LE(MAX, 1);
    }

    return buffer;
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0xA5;

  static int get refID => 0xA5;

  @override
  String get name => 'VarBinary';

  @override
  int? resolveLength(Parameter parameter) {
    final value = parameter.value; // Temporary solution. Remove 'any' later.
    if (parameter.length != null) {
      return parameter.length;
    } else if (value != null) {
      return value.length;
    } else {
      return maximumLength;
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
  String get type => 'BIGVARBIN';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }
    if (!Buffer.isBuffer(value)) {
      throw MTypeError('Invalid buffer.');
    }
    return value;
  }
}
