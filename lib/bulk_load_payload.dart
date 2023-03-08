import 'dart:async';

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/bulk_load.dart';

class BulkLoadPayload extends Stream<Buffer> {
  final BulkLoad bulkLoad;
  late RowTransform<Buffer> iterator;

  BulkLoadPayload({required this.bulkLoad}) {
    //TODO
    iterator = bulkLoad.rowToPacketTransform;
  }

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    throw UnimplementedError();
  }

  @override
  String toString({String indent = ''}) {
    return '$indent BulkLoad';
  }
}

// //! ?? !//
// typedef AsyncIterator<T> = Iterator<Future<T>>;
// typedef AsyncIterable<T> = Iterable<Future<T>>;
