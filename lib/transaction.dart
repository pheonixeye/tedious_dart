// ignore_for_file: constant_identifier_names, curly_braces_in_flow_control_structures

import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/all_headers.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/src/tracking_buffer/writable_tracking_buffer.dart';

const Map<String, num> OPERATION_TYPE = {
  "TM_GET_DTC_ADDRESS": 0x00,
  "TM_PROPAGATE_XACT": 0x01,
  "TM_BEGIN_XACT": 0x05,
  "TM_PROMOTE_XACT": 0x06,
  "TM_COMMIT_XACT": 0x07,
  "TM_ROLLBACK_XACT": 0x08,
  "TM_SAVE_XACT": 0x09
};

const Map<String, num> ISOLATION_LEVEL = {
  "NO_CHANGE": 0x00,
  "READ_UNCOMMITTED": 0x01,
  "READ_COMMITTED": 0x02,
  "REPEATABLE_READ": 0x03,
  "SERIALIZABLE": 0x04,
  "SNAPSHOT": 0x05,
};

//TODO: what is wrong with dart enums??

// enum _IsolationLevel {
//   noChange("NO_CHANGE", 0x00),
//   readUncommitted("READ_UNCOMMITTED", 0x01),
//   readCommitted("READ_COMMITTED", 0x02),
//   repeatableRead("REPEATABLE_READ", 0x03),
//   serializable("SERIALIZABLE", 0x04),
//   snapshot("SNAPSHOT", 0x05);

//   final String label;
//   final num value;
//   const _IsolationLevel(this.label, this.value);
// }

final Map<num, String> isolationLevelByValue =
    ISOLATION_LEVEL.map((key, value) => MapEntry(value, key));

assertValidIsolationLevel(dynamic isolationLevel, String name) {
  if (isolationLevel.runtimeType != int) {
    throw MTypeError(
        "The $name ${name.contains('.') ? 'property' : 'argument'} must be of type number. Received type ${isolationLevel.runtimeType} ($isolationLevel)");
  }

  //!useless??
  // if (!Number.isInteger(isolationLevel)) {
  //   throw RangeError(
  //       "The value of '$name' is out of range. It must be an integer. Received: $isolationLevel");
  // }

  if (!(isolationLevel >= 0 && isolationLevel <= 5)) {
    throw RangeError(
        "The value of '$name' is out of range. It must be >= 0 && <= 5. Received: $isolationLevel");
  }
}

class Transaction {
  String name;
  num? isolationLevel;
  num? outstandingRequestCount;

  Transaction({
    required this.name,
    this.isolationLevel,
    this.outstandingRequestCount,
  }) {
    isolationLevel = ISOLATION_LEVEL['NO_CHANGE']!;
    outstandingRequestCount = 1;
  }

  beginPayload(Buffer txnDescriptor) async* {
    var buffer = WritableTrackingBuffer(initialSize: 100, encoding: 'ucs2');
    writeToTrackingBuffer(
        buffer: buffer,
        txnDescriptor: txnDescriptor.buffer,
        outstandingRequestCount: outstandingRequestCount as int);
    buffer.writeUShort(OPERATION_TYPE['TM_BEGIN_XACT']! as int);
    buffer.writeUInt8(isolationLevel as int);
    buffer.writeUInt8(name.length * 2);
    buffer.writeString(name, 'ucs2');

    @override
    String toString() =>
        'Begin Transaction: name= $name, isolationLevel=${isolationLevelByValue[isolationLevel]!}';

    yield buffer.data;
    yield toString();
  }

  commitPayload(Buffer txnDescriptor) async* {
    var buffer = WritableTrackingBuffer(initialSize: 100, encoding: 'ascii');
    writeToTrackingBuffer(
      buffer: buffer,
      txnDescriptor: txnDescriptor.buffer,
      outstandingRequestCount: outstandingRequestCount as int,
    );
    buffer.writeUShort(OPERATION_TYPE['TM_COMMIT_XACT']! as int);
    buffer.writeUInt8(name.length * 2);
    buffer.writeString(name, 'ucs2');
    // No fBeginXact flag, so no new transaction is started.
    buffer.writeUInt8(0);

    @override
    String toString() => 'Commit Transaction: name= $name';

    yield buffer.data;
    yield toString();
  }

  rollbackPayload(Buffer txnDescriptor) async* {
    var buffer = WritableTrackingBuffer(
      initialSize: 100,
      encoding: 'ascii',
    );
    writeToTrackingBuffer(
      buffer: buffer,
      txnDescriptor: txnDescriptor.buffer,
      outstandingRequestCount: outstandingRequestCount as int,
    );
    buffer.writeUShort(OPERATION_TYPE['TM_ROLLBACK_XACT']! as int);
    buffer.writeUInt8(name.length * 2);
    buffer.writeString(name, 'ucs2');
    // No fBeginXact flag, so no new transaction is started.
    buffer.writeUInt8(0);
    @override
    String toString() => 'Rollback Transaction: name== $name';

    yield buffer.data;
    yield toString();
  }

  savePayload(Buffer txnDescriptor) async* {
    var buffer = WritableTrackingBuffer(initialSize: 100, encoding: 'ascii');
    writeToTrackingBuffer(
      buffer: buffer,
      txnDescriptor: txnDescriptor.buffer,
      outstandingRequestCount: outstandingRequestCount as int,
    );
    buffer.writeUShort(OPERATION_TYPE['TM_SAVE_XACT']! as int);
    buffer.writeUInt8(name.length * 2);
    buffer.writeString(name, 'ucs2');
    // yield buffer.data;
    @override
    String toString() => 'Save Transaction: name= $name';

    yield buffer.data;
    yield toString();

    //TODO: check if working
  }

  String isolationLevelToTSQL() {
    if (isolationLevel == ISOLATION_LEVEL['NO_CHANGE']!) return 'NO_CHANGE';

    if (isolationLevel == ISOLATION_LEVEL['READ_UNCOMMITTED']!)
      return 'READ_UNCOMMITTED';

    if (isolationLevel == ISOLATION_LEVEL['READ_COMMITTED']!)
      return 'READ_COMMITTED';

    if (isolationLevel == ISOLATION_LEVEL['REPEATABLE_READ']!)
      return 'REPEATABLE_READ';

    if (isolationLevel == ISOLATION_LEVEL['SERIALIZABLE']!)
      return 'SERIALIZABLE';

    if (isolationLevel == ISOLATION_LEVEL['SNAPSHOT']!) return 'SNAPSHOT';

    return '';
  }
}
