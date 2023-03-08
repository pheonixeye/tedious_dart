// ignore_for_file: constant_identifier_names, non_constant_identifier_names, library_prefixes

import 'dart:math' as Math;
import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/models/buffer_encoding.dart';
// ignore: unused_import

const SHIFT_LEFT_32 = (1 << 16) * (1 << 16);
const SHIFT_RIGHT_32 = 1 / SHIFT_LEFT_32;
final UNKNOWN_PLP_LEN =
    Buffer.from([0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
final ZERO_LENGTH_BUFFER = Buffer.from([0]);

class WritableTrackingBuffer {
  int initialSize;
  String? encoding;
  bool? doubleSizeGrowth;
  Buffer? buffer;
  Buffer? compositeBuffer;
  int position = 0;

  WritableTrackingBuffer({
    required this.initialSize,
    this.encoding,
    this.doubleSizeGrowth,
  }) {
    initialSize = initialSize;
    encoding = encoding ?? BufferEncoding.ucs2.type;
    doubleSizeGrowth = doubleSizeGrowth ?? false;
    buffer = Buffer.alloc(initialSize, 0);
    compositeBuffer = ZERO_LENGTH_BUFFER;
    position = 0;
  }

  Buffer? get data {
    newBuffer(0);
    return compositeBuffer;
  }

  copyFrom(Buffer buffer) {
    var length = buffer.length;
    makeRoomFor(length);
    buffer.copy(this.buffer!, position);
    position += length;
  }

  makeRoomFor(int requiredLength) {
    if (buffer!.length - position < requiredLength) {
      if (doubleSizeGrowth == true) {
        var size = Math.max(128, buffer!.length * 2);
        while (size < requiredLength) {
          size *= 2;
        }
        newBuffer(size);
      } else {
        newBuffer(requiredLength);
      }
    }
  }

  newBuffer(int size) {
    final _buffer = buffer!.slice(0, position);
    compositeBuffer = Buffer.concat([compositeBuffer!, _buffer]);
    buffer = size == 0 ? ZERO_LENGTH_BUFFER : Buffer.alloc(0);
    position = 0;
  }

  writeUInt8(int value) {
    const length = 1;
    makeRoomFor(length);
    buffer!.fill(position.toInt(), value.toInt());
    position += length;
  }

  writeUInt16LE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer!.writeUInt16LE(value, position);
    position += length;
  }

  writeUShort(int value) {
    writeUInt16LE(value);
  }

  writeUInt16BE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer!.writeUInt16BE(value, position);
    position += length;
  }

  writeUInt24LE(int value) {
    const length = 3;
    makeRoomFor(length);
    buffer![position + 2] = (value >>> 16) & 0xff;
    buffer![position + 1] = (value >>> 8) & 0xff;
    buffer![position] = value & 0xff;
    position += length;
  }

  writeUInt32LE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer!.writeUInt32LE(value, position);
    position += length;
  }

  writeBigInt64LE(int value) {
    const length = 8;
    makeRoomFor(length);
    buffer!.writeBigInt64LE(value, position);
    position += length;
  }

  writeInt64LE(int value) {
    writeBigInt64LE(value);
  }

  writeUInt64LE(int value) {
    writeBigUInt64LE(value);
  }

  writeBigUInt64LE(int value) {
    const length = 8;
    makeRoomFor(length);
    buffer!.writeBigUInt64LE(value, position);
    position += length;
  }

  writeUInt32BE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer!.writeUInt32BE(value, position);
    position += length;
  }

  writeUInt40LE(int value) {
    // inspired by https://github.com/dpw/node-buffer-more-ints
    writeInt32LE(value & -1);
    writeUInt8((value * SHIFT_RIGHT_32).floor());
  }

  writeInt8(int value) {
    const length = 1;
    makeRoomFor(length);
    buffer!.writeInt8(value, position);
    position += length;
  }

  writeInt16LE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer!.writeInt16LE(value, position);
    position += length;
  }

  writeInt16BE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer!.writeInt16BE(value, position);
    position += length;
  }

  writeInt32LE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer!.writeInt32LE(value, position);
    position += length;
  }

  writeInt32BE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer!.writeInt32BE(value, position);
    position += length;
  }

  writeFloatLE(double value) {
    const length = 4;
    makeRoomFor(length);
    buffer!.writeFloatLE(value, position);
    position += length;
  }

  writeDoubleLE(double value) {
    const length = 8;
    makeRoomFor(length);
    buffer!.writeDoubleLE(value, position);
    position += length;
  }

  writeString(String value, String? encoding) {
    encoding ??= this.encoding;

    final length = Buffer.byteLength(value, encoding!);
    makeRoomFor(length);

    // $FlowFixMe https://github.com/facebook/flow/pull/5398
    //!!!!!!!!!!!!!!!!!!!//TODO: CHECK IMPLEMENTATION
    buffer!.write(
      value,
      offset: position,
      length: length,
      encoding: encoding,
    );
    position += length;
  }

  writeBVarchar(String value, String? encoding) {
    writeUInt8(value.length);
    writeString(value, encoding);
  }

  writeUsVarchar(String value, String? encoding) {
    writeUInt16LE(value.length);
    writeString(value, encoding);
  }

  writeBuffer(Buffer value) {
    final length = value.length;
    makeRoomFor(length);
    value.copy(buffer!, position);
    position += length;
  }

  // TODO: Figure out what types are passed in other than `Buffer`
  writeUsVarbyte(dynamic value, String? encoding) {
    encoding ??= this.encoding;

    late int length;
    //?
    if (value.runtimeType == Buffer) {
      length = value.length;
    } else {
      value = value.toString();
      length = Buffer.byteLength(value, encoding!);
    }
    writeUInt16LE(length);
    //?
    if (value.runtimeType == Buffer) {
      writeBuffer(value);
    } else {
      makeRoomFor(length);
      // $FlowFixMe https://github.com/facebook/flow/pull/5398
      buffer!.write(value,
          offset: position, length: length, encoding: encoding ?? 'utf-8');
      position += length;
    }
  }

  writePLPBody(dynamic value, String? encoding) {
    encoding ??= this.encoding;

    late int length;
    if (value.runtimeType == Buffer) {
      length = value.length;
    } else {
      value = value.toString();
      length = Buffer.byteLength(value, encoding!);
    }

    // Length of all chunks.
    // this.writeUInt64LE(length);
    // unknown seems to work better here - might revisit later.
    writeBuffer(UNKNOWN_PLP_LEN);

    // In the UNKNOWN_PLP_LEN case, the data is represented as a series of zero or more chunks.
    if (length > 0) {
      // One chunk.
      writeUInt32LE(length);
      if (value.runtimeType == Buffer) {
        writeBuffer(value);
      } else {
        makeRoomFor(length);
        buffer!.write(value,
            offset: position, length: length, encoding: encoding ?? 'utf-8');
        position += length;
      }
    }
  }

  writeMoney(int value) {
    writeInt32LE((value * SHIFT_RIGHT_32).floor());
    writeInt32LE(value & -1);
  }
}
