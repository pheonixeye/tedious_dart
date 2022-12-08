// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_this, library_prefixes

import 'dart:typed_data';
import 'dart:math' as Math;
import 'package:tedious_dart/models/buffer.dart';
import 'package:tedious_dart/models/buffer_encoding.dart';

const SHIFT_LEFT_32 = (1 << 16) * (1 << 16);
const SHIFT_RIGHT_32 = 1 / SHIFT_LEFT_32;
final UNKNOWN_PLP_LEN =
    Buffer.fromList([0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
final ZERO_LENGTH_BUFFER = Buffer.fromList([0]);

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
    buffer = Buffer(this.initialSize);
    compositeBuffer = ZERO_LENGTH_BUFFER;
    position = 0;
  }

  Buffer? get data {
    this.newBuffer(0);
    return this.compositeBuffer;
  }

  copyFrom(Uint8List buffer) {
    var length = buffer.length;
    this.makeRoomFor(length);
    buffer.insertAll(this.position.toInt(), this.buffer as Iterable<int>);
    this.position += length;
  }

  makeRoomFor(int requiredLength) {
    if (this.buffer!.length - this.position < requiredLength) {
      if (this.doubleSizeGrowth == true) {
        var size = Math.max(128, this.buffer!.length * 2);
        while (size < requiredLength) {
          size *= 2;
        }
        this.newBuffer(size);
      } else {
        this.newBuffer(requiredLength);
      }
    }
  }

  newBuffer(int size) {
    final buffer = this.buffer!.slice(size, 0, this.position);
    this.compositeBuffer = buffer.concat(
        [this.compositeBuffer!.list, buffer.list] as Uint8List,
        (this.compositeBuffer!.length + buffer.length));
    this.buffer = size == 0 ? ZERO_LENGTH_BUFFER : Buffer(0);
    this.position = 0;
  }

  writeUInt8(int value) {
    const length = 1;
    this.makeRoomFor(length);
    this.buffer!.fill(this.position.toInt(), value.toInt());
    this.position += length;
  }

  writeUInt16LE(int value) {
    const length = 2;
    this.makeRoomFor(length);
    this.buffer!.writeUInt16LE(value, this.position);
    this.position += length;
  }

  writeUShort(int value) {
    this.writeUInt16LE(value);
  }

  writeUInt16BE(int value) {
    const length = 2;
    this.makeRoomFor(length);
    this.buffer!.writeUInt16BE(value, this.position);
    this.position += length;
  }

  writeUInt24LE(int value) {
    const length = 3;
    this.makeRoomFor(length);
    this.buffer![this.position + 2] = (value >>> 16) & 0xff;
    this.buffer![this.position + 1] = (value >>> 8) & 0xff;
    this.buffer![this.position] = value & 0xff;
    this.position += length;
  }

  writeUInt32LE(int value) {
    const length = 4;
    this.makeRoomFor(length);
    this.buffer!.writeUInt32LE(value, this.position);
    this.position += length;
  }

  writeBigInt64LE(int value) {
    const length = 8;
    this.makeRoomFor(length);
    this.buffer!.writeBigInt64LE(value, this.position);
    this.position += length;
  }

  writeInt64LE(int value) {
    this.writeBigInt64LE(value);
  }

  writeUInt64LE(int value) {
    this.writeBigUInt64LE(value);
  }

  writeBigUInt64LE(int value) {
    const length = 8;
    this.makeRoomFor(length);
    this.buffer!.writeBigUInt64LE(value, this.position);
    this.position += length;
  }

  writeUInt32BE(int value) {
    const length = 4;
    this.makeRoomFor(length);
    this.buffer!.writeUInt32BE(value, this.position);
    this.position += length;
  }

  writeUInt40LE(int value) {
    // inspired by https://github.com/dpw/node-buffer-more-ints
    this.writeInt32LE(value & -1);
    this.writeUInt8((value * SHIFT_RIGHT_32).floor());
  }

  writeInt8(int value) {
    const length = 1;
    this.makeRoomFor(length);
    this.buffer!.writeInt8(value, this.position);
    this.position += length;
  }

  writeInt16LE(int value) {
    const length = 2;
    this.makeRoomFor(length);
    this.buffer!.writeInt16LE(value, this.position);
    this.position += length;
  }

  writeInt16BE(int value) {
    const length = 2;
    this.makeRoomFor(length);
    this.buffer!.writeInt16BE(value, this.position);
    this.position += length;
  }

  writeInt32LE(int value) {
    const length = 4;
    this.makeRoomFor(length);
    this.buffer!.writeInt32LE(value, this.position);
    this.position += length;
  }

  writeInt32BE(int value) {
    const length = 4;
    this.makeRoomFor(length);
    this.buffer!.writeInt32BE(value, this.position);
    this.position += length;
  }

  writeFloatLE(double value) {
    const length = 4;
    this.makeRoomFor(length);
    this.buffer!.writeFloatLE(value, this.position);
    this.position += length;
  }

  writeDoubleLE(double value) {
    const length = 8;
    this.makeRoomFor(length);
    this.buffer!.writeDoubleLE(value, this.position);
    this.position += length;
  }

  writeString(String value, String? encoding) {
    encoding ??= this.encoding;

    final length = Buffer.byteLength(value, encoding);
    this.makeRoomFor(length);

    // $FlowFixMe https://github.com/facebook/flow/pull/5398
    this.buffer!.write(value, this.position, encoding);
    this.position += length;
  }

  writeBVarchar(String value, String? encoding) {
    this.writeUInt8(value.length);
    this.writeString(value, encoding);
  }

  writeUsVarchar(String value, String? encoding) {
    this.writeUInt16LE(value.length);
    this.writeString(value, encoding);
  }

  writeBuffer(Buffer value) {
    final length = value.length;
    this.makeRoomFor(length);
    value.copy(this.buffer!, this.position);
    this.position += length;
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
      length = Buffer.byteLength(value, encoding);
    }
    this.writeUInt16LE(length);
    //?
    if (value.runtimeType == Buffer) {
      writeBuffer(value);
    } else {
      this.makeRoomFor(length);
      // $FlowFixMe https://github.com/facebook/flow/pull/5398
      this.buffer!.write(value, this.position, encoding);
      this.position += length;
    }
  }

  writePLPBody(dynamic value, String? encoding) {
    encoding ??= this.encoding;

    late int length;
    if (value.runtimeType == Buffer) {
      length = value.length;
    } else {
      value = value.toString();
      length = Buffer.byteLength(value, encoding);
    }

    // Length of all chunks.
    // this.writeUInt64LE(length);
    // unknown seems to work better here - might revisit later.
    this.writeBuffer(UNKNOWN_PLP_LEN);

    // In the UNKNOWN_PLP_LEN case, the data is represented as a series of zero or more chunks.
    if (length > 0) {
      // One chunk.
      this.writeUInt32LE(length);
      if (value.runtimeType == Buffer) {
        this.writeBuffer(value);
      } else {
        this.makeRoomFor(length);
        this.buffer!.write(value, this.position, encoding);
        this.position += length;
      }
    }
  }

  writeMoney(int value) {
    this.writeInt32LE((value * SHIFT_RIGHT_32).floor());
    this.writeInt32LE(value & -1);
  }
}
