// const OPTION = {
//   WITH_RECOMPILE: 0x01,
//   NO_METADATA: 0x02,
//   REUSE_METADATA: 0x04
// };

// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/all_headers.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/src/tracking_buffer/writable_tracking_buffer.dart';

const Map<String, int> STATUS = {
  'BY_REF_VALUE': 0x01,
  'DEFAULT_VALUE': 0x02,
};

//TODO: Iterable<Buffer>
class RpcRequestPayload extends Stream<Buffer> {
  dynamic procedure;
  // string | number;
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

  generateData() async* {
    final buffer = WritableTrackingBuffer(initialSize: 500);
    if (this.options.tdsVersion != '7_2') {
      const outstandingRequestCount = 1;
      writeToTrackingBuffer(
        buffer: buffer,
        txnDescriptor: this.txnDescriptor.buffer,
        outstandingRequestCount: outstandingRequestCount,
      );
    }

    if (this.procedure is String) {
      buffer.writeUsVarchar(this.procedure as String, 'ucs-2');
    } else {
      buffer.writeUShort(0xFFFF);
      buffer.writeUShort(this.procedure);
    }

    const optionFlags = 0;
    buffer.writeUInt16LE(optionFlags);
    yield buffer.data;

    final parametersLength = this.parameters.length;
    for (int i = 0; i < parametersLength; i++) {
      yield* this.generateParameterData(this.parameters[i]);
    }
  }

  @override
  toString({String indent = ''}) {
    return indent + ('RPC Request - ' + this.procedure);
  }

  generateParameterData(Parameter parameter) async* {
    final buffer = WritableTrackingBuffer(
        initialSize:
            1 + 2 + Buffer.byteLength(parameter.name, 'ucs-2').length + 1);
    buffer.writeBVarchar('@' + parameter.name!, 'ucs-2');

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

    if (this.collation != null) {
      param.collation = this.collation;
    }

    yield type.generateTypeInfo(param, this.options);
    yield type.generateParameterLength(param, this.options);
    yield* type.generateParameterData(param, this.options);
  }

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }
}
