import 'dart:async';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/extensions/to_iterable_on_stream.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';
import 'package:tedious_dart/all_headers.dart';
import 'package:tedious_dart/tds_versions.dart';

class SqlBatchPayload extends Iterable<Buffer> {
  String sqlText;
  Buffer txnDescriptor;
  String tdsVersion;

  SqlBatchPayload({
    required this.sqlText,
    required this.txnDescriptor,
    required this.tdsVersion,
  });

  Stream<Buffer> iterate() async* {
    if (TDSVERSIONS[tdsVersion]! >= TDSVERSIONS['7_2']!) {
      var buffer = WritableTrackingBuffer(initialSize: 18, encoding: 'ucs2');
      const outstandingRequestCount = 1;

      writeToTrackingBuffer(
        buffer: buffer,
        txnDescriptor: txnDescriptor,
        outstandingRequestCount: outstandingRequestCount,
      );

      yield buffer.data;
    }

    yield Buffer.from(sqlText, 0, 0, 'ucs2');
  }

  @override
  toString({String indent = ''}) {
    return indent + ('SQL Batch - $sqlText');
  }

  @override
  Iterator<Buffer> get iterator {
    late Iterator<Buffer> i;
    iterate().toList().then((value) => i = value.iterator);
    return i;
  }
}


//*[Symbol.iterator] implementation in dart