// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/src/tracking_buffer/writable_tracking_buffer.dart';

const TXNDESCRIPTOR_HEADER_DATA_LEN = 4 + 8;

const TXNDESCRIPTOR_HEADER_LEN = 4 + 2 + TXNDESCRIPTOR_HEADER_DATA_LEN;

enum TYPE {
  QUERY_NOTIFICATIONS(1),
  TXN_DESCRIPTOR(2),
  TRACE_ACTIVITY(3);

  final int value;
  const TYPE(this.value);
}

WritableTrackingBuffer writeToTrackingBuffer({
  required WritableTrackingBuffer buffer,
  required Uint8List txnDescriptor,
  required int outstandingRequestCount,
}) {
  buffer.writeUInt32LE(0);
  buffer.writeUInt32LE(TXNDESCRIPTOR_HEADER_LEN);
  buffer.writeUInt16LE(TYPE.TXN_DESCRIPTOR.value);
  buffer.writeBuffer(Buffer.from(txnDescriptor));
  buffer.writeUInt32LE(outstandingRequestCount);

  final data = buffer.data;
  data!.writeUInt32LE(data.length, 0);
  return buffer;
}
