// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';

const TXNDESCRIPTOR_HEADER_DATA_LEN = 4 + 8;

const TXNDESCRIPTOR_HEADER_LEN = 4 + 2 + TXNDESCRIPTOR_HEADER_DATA_LEN;

Map<String, int> HEADERTYPE = {
  'QUERY_NOTIFICATIONS': 1,
  'TXN_DESCRIPTOR': 2,
  'TRACE_ACTIVITY': 3,
};

WritableTrackingBuffer writeToTrackingBuffer({
  required WritableTrackingBuffer buffer,
  required Buffer txnDescriptor,
  required int outstandingRequestCount,
}) {
  print(LoggerStackTrace.from(StackTrace.current).toString());

  buffer.writeUInt32LE(0);
  buffer.writeUInt32LE(TXNDESCRIPTOR_HEADER_LEN);
  buffer.writeUInt16LE(HEADERTYPE['TXN_DESCRIPTOR']!);
  buffer.writeBuffer(txnDescriptor);
  buffer.writeUInt32LE(outstandingRequestCount);

  final data = buffer.data;
  data.writeUInt32LE(data.length, 0);
  return buffer;
}
