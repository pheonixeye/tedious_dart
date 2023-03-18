// const OPTION = {
//   WITH_RECOMPILE: 0x01,
//   NO_METADATA: 0x02,
//   REUSE_METADATA: 0x04
// };

// ignore_for_file: constant_identifier_names, unnecessary_null_comparison

import 'dart:async';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/all_headers.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/meta/annotations.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';

const Map<String, int> STATUS = {
  'BY_REF_VALUE': 0x01,
  'DEFAULT_VALUE': 0x02,
};

class RpcRequestPayload extends Iterable<Buffer> {
  @DynamicParameterType('procedure', 'String | int')
  dynamic procedure;
  List<Parameter> parameters;

  InternalConnectionOptions options;
  Buffer txnDescriptor;
  Collation? collation;

  RpcRequestPayload({
    this.procedure,
    this.collation,
    required this.options,
    required this.parameters,
    required this.txnDescriptor,
  });
  @DynamicReturnType('Buffer | Stream<Buffer>')
  Stream<dynamic> generateData() async* {
    final buffer = WritableTrackingBuffer(initialSize: 500);
    if (TDSVERSIONS[options.tdsVersion]! >= TDSVERSIONS['7_2']!) {
      const outstandingRequestCount = 1;
      writeToTrackingBuffer(
        buffer: buffer,
        txnDescriptor: txnDescriptor,
        outstandingRequestCount: outstandingRequestCount,
      );
    }

    if (procedure is String) {
      buffer.writeUsVarchar(procedure as String, 'ucs-2');
    } else {
      buffer.writeUShort(0xFFFF);
      buffer.writeUShort(procedure);
    }

    const optionFlags = 0;
    buffer.writeUInt16LE(optionFlags);
    yield buffer.data;

    final parametersLength = parameters.length;
    for (int i = 0; i < parametersLength; i++) {
      yield* generateParameterData(parameters[i]);
    }
  }

  @override
  toString({String indent = ''}) {
    return indent + ('RPC Request - $procedure');
  }

  Stream<Buffer> generateParameterData(Parameter parameter) async* {
    final buffer = WritableTrackingBuffer(
        initialSize: 1 + 2 + Buffer.byteLength(parameter.name, 'ucs-2') + 1);
    buffer.writeBVarchar('@${parameter.name!}', 'ucs-2');

    var statusFlags = 0;
    if (parameter.output != null) {
      statusFlags |= STATUS['BY_REF_VALUE']!;
    }
    buffer.writeUInt8(statusFlags);

    yield buffer.data;

    final param = ParameterData(value: parameter.value);

    var type = parameter.type;

    if ((type!.id & 0x30) == 0x20) {
      if (parameter.length != null) {
        param.length = parameter.length;
      } else if (type.resolveLength != null) {
        param.length = type.resolveLength(parameter);
      }
    }

    if (parameter.precision != null) {
      param.precision = parameter.precision;
    } else if (type.resolvePrecision != null) {
      param.precision = type.resolvePrecision(parameter);
    }

    if (parameter.scale != null) {
      param.scale = parameter.scale;
    } else if (type.resolveScale != null) {
      param.scale = type.resolveScale(parameter);
    }

    if (collation != null) {
      param.collation = collation;
    }

    yield type.generateTypeInfo(param, options);
    yield type.generateParameterLength(param, options);
    yield* type.generateParameterData(param, options);
  }

  @override
  Iterator<Buffer> get iterator => throw UnimplementedError();
}
