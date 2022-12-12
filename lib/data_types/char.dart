// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'package:tedious_dart/models/buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/models/data_types.dart';

final NULL_LENGTH = Buffer.fromList([0xFF, 0xFF]);

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

    yield Buffer.fromString(parameter.value, 'ascii');
  }

  @override
  Buffer generateParameterLength(ParameterData parameter, options) {
    final value = parameter.value as Buffer?;

    if (value == null) {
      return NULL_LENGTH;
    }

    final buffer = Buffer(2);
    buffer.writeUInt16LE(value.length, 0);
    return buffer;
  }

  @override
  Buffer generateTypeInfo(ParameterData parameter, options) {
    final buffer = Buffer(8);
    buffer.writeUInt8(this.id, 0);
    buffer.writeUInt16LE(parameter.length!, 1);

    if (parameter.collation != null) {
      //TODO: copy method implementation??

      // parameter.collation!.toBuffer().copy(buffer, 3, 0, 5);//! original

      parameter.collation!.toBuffer().copy(buffer, 0, 5);
    }

    return buffer;
  }

  @override
  // TODO: implement hasTableName
  bool? get hasTableName => throw UnimplementedError();

  @override
  int get id => 0xAF;

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
    // TODO: implement resolvePrecision
    throw UnimplementedError();
  }

  @override
  num? resolveScale(Parameter parameter) {
    // TODO: implement resolveScale
    throw UnimplementedError();
  }

  @override
  String get type => 'BIGCHAR';

  @override
  validate(value, Collation? collation) {
    // TODO: implement validate
    throw UnimplementedError();
  }
}
