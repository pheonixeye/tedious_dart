import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/src/tracking_buffer/writable_tracking_buffer.dart';
import 'package:tedious_dart/all_headers.dart';

class SqlBatchPayload extends Iterable<Buffer> {
  String sqlText;
  Buffer txnDescriptor;
  String tdsVersion;

  SqlBatchPayload(
      {required this.sqlText,
      required this.txnDescriptor,
      required this.tdsVersion});

  iterate() async* {
    if (tdsVersion == '7_2') {
      var buffer = WritableTrackingBuffer(initialSize: 18, encoding: 'ucs2');
      const outstandingRequestCount = 1;

      writeToTrackingBuffer(
        buffer: buffer,
        txnDescriptor: txnDescriptor.buffer,
        outstandingRequestCount: outstandingRequestCount,
      );

      yield buffer.data;
    }

    yield Buffer.from(sqlText, 'ucs2');
  }

  @override
  toString({String indent = ''}) {
    return indent + ('SQL Batch - $sqlText');
  }

  @override
  Iterator<Buffer> get iterator => throw UnimplementedError();
}


//*[Symbol.iterator] implementation in dart