// ignore_for_file: non_constant_identifier_names, constant_identifier_names

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

class NVarChar extends DataType {
  final int maximumLength;

  NVarChar({this.maximumLength = 4000});

  @override
  String declaration(Parameter parameter) {
    final value =
        parameter.value; // Temporary solution. Remove 'dynamic' later.

    int length;
    if (parameter.length != null) {
      length = parameter.length!;
    } else if (value != null) {
      length = value.toString().isEmpty ? 1 : value.toString().length;
    } else if (value == null && parameter.output == false) {
      length = 1;
    } else {
      length = maximumLength;
    }

    if (length <= maximumLength) {
      return 'nvarchar(' '$length' ')';
    } else {
      return 'nvarchar(max)';
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
      if (value is Buffer) {
        yield value;
      } else {
        value = value.toString();
        yield Buffer.from(value, 'ucs2');
      }
    } else {
      if (value is Buffer) {
        final length = value.length;

        if (length > 0) {
          final buffer = Buffer.alloc(4);
          buffer.writeUInt32LE(length, 0);
          yield buffer;
          yield value;
        }
      } else {
        value = value.toString();
        final length = Buffer.byteLength(value, 'ucs2').length;

        if (length > 0) {
          final buffer = Buffer.alloc(4);
          buffer.writeUInt32LE(length, 0);
          yield buffer;
          yield Buffer.from(value, 'ucs2');
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

    var value = parameter.value;
    if (parameter.length! <= maximumLength) {
      int length;
      if (value is Buffer) {
        length = value.length;
      } else {
        value = value.toString();
        length = Buffer.byteLength(value.toString(), 'ucs2').length;
      }

      final buffer = Buffer.alloc(2);
      buffer.writeUInt16LE(length, 0);
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
      buffer.writeUInt16LE(parameter.length! * 2, 1);
    } else {
      buffer.writeUInt16LE(MAX, 1);
    }

    if (parameter.collation != null) {
      parameter.collation!.toBuffer().copy(buffer, 3, 0, 5);
    }

    return buffer;
  }

  @override
  // TODO: implement hasTableName
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0xE7;

  static int get refID => 0xE7;

  @override
  String get name => 'NVarChar';

  @override
  int? resolveLength(Parameter parameter) {
    final value = parameter.value; // Temporary solution. Remove 'any' later.
    if (parameter.length != null) {
      return parameter.length;
    } else if (value != null) {
      if (Buffer.isBuffer(value)) {
        return (parameter.value.length / 2) == 0
            ? 1
            : (parameter.value.length / 2);
      } else {
        return value.toString().isEmpty ? 1 : value.toString().length;
      }
    } else {
      return maximumLength;
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
  String get type => 'NVARCHAR';

  @override
  validate(value, Collation? collation) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw MTypeError('Invalid string.');
    }

    return value;
  }
}
