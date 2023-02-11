// ignore_for_file: non_constant_identifier_names

import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

final NULL_LENGTH = Buffer.from([0xFF, 0xFF]);

class NChar extends DataType {
  final int maximumLength;
  NChar({
    this.maximumLength = 4000,
  });
  @override
  String declaration(Parameter parameter) {
    // const value = parameter.value as null | string | { toString(): string };
    final value =
        parameter.value; // Temporary solution. Remove 'dynamic' later.

    int length;
    if (parameter.length != null) {
      length = parameter.length!;
    } else if (parameter.value != null) {
      length = value.toString().isEmpty ? 1 : value.toString().length;
    } else if (parameter.value == null && parameter.output == false) {
      length = 1;
    } else {
      length = maximumLength;
    }

    if (length < maximumLength) {
      return 'nchar(' ' $length ' ')';
    } else {
      return 'nchar(' ' $maximumLength ' ')';
    }
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, InternalConnectionOptions options) async* {
    if (parameter.value == null) {
      return;
    }

    final value = parameter.value;
    if (value is Buffer) {
      yield value;
    } else {
      yield Buffer.from(value, 'ucs2');
    }
  }

  @override
  Buffer generateParameterLength(
      ParameterData parameter, InternalConnectionOptions options) {
    if (parameter.value == null) {
      return NULL_LENGTH;
    }

    //TODO: const { value } = parameter;
    final value = parameter.value;
    if (value is Buffer) {
      final length = value.length;
      final buffer = Buffer.alloc(2);

      buffer.writeUInt16LE(length, 0);

      return buffer;
    } else {
      final length = Buffer.byteLength(value.toString(), 'ucs2');

      final buffer = Buffer.alloc(2);
      buffer.writeUInt16LE(length.length, 0);
      return buffer;
    }
  }

  @override
  Buffer generateTypeInfo(
      ParameterData parameter, InternalConnectionOptions options) {
    final buffer = Buffer.alloc(8);
    buffer.writeUInt8(id, 0);
    buffer.writeUInt16LE(parameter.length! * 2, 1);

    if (parameter.collation != null) {
      parameter.collation!.toBuffer().copy(buffer, 3, 0, 5);
    }

    return buffer;
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0xEF;

  static int get refID => 0xEF;

  @override
  String get name => 'NChar';

  @override
  int? resolveLength(Parameter parameter) {
    final value = parameter.value; // Temporary solution. Remove 'any' later.

    if (parameter.length != null) {
      return parameter.length;
    } else if (parameter.value != null) {
      if (Buffer.isBuffer(parameter.value)) {
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
    throw UnimplementedError();
  }

  @override
  num? resolveScale(Parameter parameter) {
    throw UnimplementedError();
  }

  @override
  String get type => 'NCHAR';

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
