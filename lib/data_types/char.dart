// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'package:charset_converter/charset_converter.dart';
import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';

final NULL_LENGTH = Buffer.from([0xFF, 0xFF]);

class Char extends DataType {
  int maximumLength;

  Char({this.maximumLength = 8000});
  @override
  String declaration(Parameter parameter) {
    final value = parameter.value as Buffer?;

    late int length;
    if (parameter.length != null) {
      length = parameter.length!;
    } else if (value != null) {
      length = value.length == 0 ? 1 : value.length;
    } else if (value == null && !parameter.output) {
      length = 1;
    } else {
      length = this.maximumLength;
    }

    if (length < this.maximumLength) {
      return "char('$length')";
    } else {
      return "char('${this.maximumLength}')";
    }
  }

  @override
  Stream<Buffer> generateParameterData(
      ParameterData parameter, options) async* {
    if (parameter.value == null) {
      return;
    }

    yield Buffer.from(parameter.value, 'ascii');
  }

  @override
  Buffer generateParameterLength(ParameterData parameter, options) {
    final value = parameter.value as Buffer?;

    if (value == null) {
      return NULL_LENGTH;
    }

    final buffer = Buffer.alloc(2);
    buffer.writeUInt16LE(value.length, 0);
    return buffer;
  }

  @override
  Buffer generateTypeInfo(ParameterData parameter, options) {
    final buffer = Buffer.alloc(8);
    buffer.writeUInt8(id, 0);
    buffer.writeUInt16LE(parameter.length!, 1);

    if (parameter.collation != null) {
      parameter.collation!.toBuffer().copy(buffer, 3, 0, 5); //! original

      // parameter.collation!.toBuffer().copy(buffer, 0, 5);
    }

    return buffer;
  }

  @override
  bool? get hasTableName => throw UnimplementedError();

  @override
  static int get id => 0xAF;

  @override
  String get name => 'Char';

  @override
  int? resolveLength(Parameter parameter) {
    final value = parameter.value as Buffer?;

    if (parameter.length != null) {
      return parameter.length;
    } else if (value != null) {
      return value.length == 0 ? 1 : value.length;
    } else {
      return this.maximumLength;
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
  String get type => 'BIGCHAR';

  @override
  validate(value, Collation? collation) async {
    if (value == null) {
      return null;
    }

    if (value.runtimeType != String) {
      throw ArgumentError('Invalid string.');
    }

    if (collation == null) {
      throw ArgumentError(
          'No collation was set by the server for the current connection.');
    }

    if (collation.codepage == null) {
      throw ArgumentError(
          'The collation set by the server has no associated encoding.');
    }

    final result = await CharsetConverter.encode(collation.codepage!, value);

    return result;
  }
}
