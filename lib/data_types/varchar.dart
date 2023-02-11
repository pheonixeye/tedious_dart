// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/connection.dart';
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

class VarChar extends DataType {
  final int maximumLength;
  VarChar({this.maximumLength = 8000});

  @override
  String declaration(Parameter parameter) {
    final value = parameter.value as Buffer?;

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
      return 'varchar(' '$length' ')';
    } else {
      return 'varchar(max)';
    }
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    final value = parameter.value as Buffer?;

    if (value == null) {
      return;
    }

    if (parameter.length! <= maximumLength) {
      yield value;
    } else {
      if (value.length > 0) {
        final buffer = Buffer.alloc(4);
        buffer.writeUInt32LE(value.length, 0);
        yield buffer;

        yield value;
      }

      yield PLP_TERMINATOR;
    }
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    final value = parameter.value as Buffer?;

    if (value == null) {
      if (parameter.length! <= maximumLength) {
        return NULL_LENGTH;
      } else {
        return MAX_NULL_LENGTH;
      }
    }

    if (parameter.length! <= maximumLength) {
      final buffer = Buffer.alloc(2);
      buffer.writeUInt16LE(value.length, 0);
      return buffer;
    } else {
      return UNKNOWN_PLP_LEN;
    }
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    final buffer = Buffer.alloc(8);
    buffer.writeUInt8(id, 0);

    if (parameter.length! <= maximumLength) {
      buffer.writeUInt16LE(parameter.length!, 1);
    } else {
      buffer.writeUInt16LE(MAX, 1);
    }

    if (parameter.collation != null) {
      parameter.collation!.toBuffer().copy(buffer, 3, 0, 5);
    }

    return buffer;
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0xA7;

  static int get refID => 0xA7;

  @override
  String get name => 'VarChar';

  @override
  int? resolveLength(Parameter parameter) {
    final value = parameter.value as Buffer?;

    if (parameter.length != null) {
      return parameter.length;
    } else if (value != null) {
      return value.length == 0 ? 1 : value.length;
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
  String get type => 'BIGVARCHR';

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

    return iconv.encode(value, collation.codepage);
  }
}
