import 'dart:async';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';
import 'package:tedious_dart/all_headers.dart';
import 'package:tedious_dart/tds_versions.dart';

class SqlBatchPayload extends Stream<Buffer> {
  String sqlText;
  Buffer txnDescriptor;
  String tdsVersion;

  SqlBatchPayload({
    required this.sqlText,
    required this.txnDescriptor,
    required this.tdsVersion,
  });

  iterate() async* {
    //todo: mod "==" to ">="
    //versions from ../tds_versions.dart
    if (TDSVERSIONS[tdsVersion]! >= TDSVERSIONS['7_2']!) {
      var buffer = WritableTrackingBuffer(initialSize: 18, encoding: 'ucs2');
      const outstandingRequestCount = 1;

      writeToTrackingBuffer(
        buffer: buffer,
        txnDescriptor: txnDescriptor.buffer,
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
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }
}


//*[Symbol.iterator] implementation in dart