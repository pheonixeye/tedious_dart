// ignore_for_file: constant_identifier_names, non_constant_identifier_names, library_prefixes

import 'dart:math' as Math;
import 'package:magic_buffer_copy/magic_buffer.dart';
// ignore: unused_import

const SHIFT_LEFT_32 = (1 << 16) * (1 << 16);
const SHIFT_RIGHT_32 = 1 / SHIFT_LEFT_32;
final UNKNOWN_PLP_LEN =
    Buffer.from([0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
final ZERO_LENGTH_BUFFER = Buffer.alloc(0);

class WritableTrackingBuffer {
  int initialSize;
  String encoding;
  bool doubleSizeGrowth;
  late Buffer buffer;
  late Buffer compositeBuffer;
  int position = 0;

  WritableTrackingBuffer({
    required this.initialSize,
    this.encoding = 'ucs2',
    this.doubleSizeGrowth = false,
  })  : buffer = Buffer.alloc(initialSize, 0),
        compositeBuffer = ZERO_LENGTH_BUFFER;

  Buffer get data {
    newBuffer(0);
    return compositeBuffer;
  }

  void copyFrom(Buffer buffer) {
    final length = buffer.length;
    makeRoomFor(length);
    buffer.copy(this.buffer, position);
    position += length;
  }

  void makeRoomFor(int requiredLength) {
    if (buffer.length - position < requiredLength) {
      if (doubleSizeGrowth == true) {
        var size = Math.max(128, buffer.length * 2);
        while (size < requiredLength) {
          size *= 2;
        }
        newBuffer(size);
      } else {
        newBuffer(requiredLength);
      }
    }
  }

  void newBuffer(int size) {
    final buffer = this.buffer.slice(0, position);
    compositeBuffer = Buffer.concat([compositeBuffer, buffer]);
    this.buffer = size == 0 ? ZERO_LENGTH_BUFFER : Buffer.alloc(size, 0);
    position = 0;
  }

  void writeUInt8(int value) {
    const length = 1;
    makeRoomFor(length);
    buffer.writeUInt8(value, position);
    position += length;
  }

  void writeUInt16LE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer.writeUInt16LE(value, position);
    position += length;
  }

  void writeUShort(int value) {
    writeUInt16LE(value);
  }

  void writeUInt16BE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer.writeUInt16BE(value, position);
    position += length;
  }

  void writeUInt24LE(int value) {
    const length = 3;
    makeRoomFor(length);
    buffer[position + 2] = (value >>> 16) & 0xff;
    buffer[position + 1] = (value >>> 8) & 0xff;
    buffer[position] = value & 0xff;
    position += length;
  }

  void writeUInt32LE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer.writeUInt32LE(value, position);
    position += length;
  }

  void writeBigInt64LE(int value) {
    const length = 8;
    makeRoomFor(length);
    buffer.writeBigInt64LE(value, position);
    position += length;
  }

  void writeInt64LE(int value) {
    writeBigInt64LE(value);
  }

  void writeUInt64LE(int value) {
    writeBigUInt64LE(value);
  }

  void writeBigUInt64LE(int value) {
    const length = 8;
    makeRoomFor(length);
    buffer.writeBigUInt64LE(value, position);
    position += length;
  }

  void writeUInt32BE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer.writeUInt32BE(value, position);
    position += length;
  }

  void writeUInt40LE(int value) {
    // inspired by https://github.com/dpw/node-buffer-more-ints
    writeInt32LE(value & -1);
    writeUInt8((value * SHIFT_RIGHT_32).floor());
  }

  void writeInt8(int value) {
    const length = 1;
    makeRoomFor(length);
    buffer.writeInt8(value, position);
    position += length;
  }

  void writeInt16LE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer.writeInt16LE(value, position);
    position += length;
  }

  void writeInt16BE(int value) {
    const length = 2;
    makeRoomFor(length);
    buffer.writeInt16BE(value, position);
    position += length;
  }

  void writeInt32LE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer.writeInt32LE(value, position);
    position += length;
  }

  void writeInt32BE(int value) {
    const length = 4;
    makeRoomFor(length);
    buffer.writeInt32BE(value, position);
    position += length;
  }

  void writeFloatLE(double value) {
    const length = 4;
    makeRoomFor(length);
    buffer.writeFloatLE(value, position);
    position += length;
  }

  void writeDoubleLE(double value) {
    const length = 8;
    makeRoomFor(length);
    buffer.writeDoubleLE(value, position);
    position += length;
  }

  void writeString(String value, String? encoding) {
    encoding ??= this.encoding;

    final length = Buffer.byteLength(value, encoding);
    makeRoomFor(length);

    // $FlowFixMe https://github.com/facebook/flow/pull/5398
    buffer.write(
      value,
      offset: position,
      encoding: encoding,
    );
    position += length;
  }

  void writeBVarchar(String value, String? encoding) {
    writeUInt8(value.length);
    writeString(value, encoding);
  }

  void writeUsVarchar(String value, String? encoding) {
    writeUInt16LE(value.length);
    writeString(value, encoding);
  }

  void writeBuffer(Buffer value) {
    final length = value.length;
    makeRoomFor(length);
    value.copy(buffer, position);
    position += length;
  }

  // TODO: Figure out what types are passed in other than `Buffer`
  void writeUsVarbyte(dynamic value, String? encoding) {
    encoding ??= this.encoding;

    int length;
    //?
    if (value is Buffer) {
      length = value.length;
    } else {
      value = value.toString();
      length = Buffer.byteLength(value, encoding);
    }
    writeUInt16LE(length);
    //?
    if (value is Buffer) {
      writeBuffer(value);
    } else {
      makeRoomFor(length);
      // $FlowFixMe https://github.com/facebook/flow/pull/5398
      buffer.write(value,
          offset: position, encoding: encoding == '' ? 'utf-8' : encoding);
      position += length;
    }
  }

  void writePLPBody(dynamic value, String? encoding) {
    encoding ??= this.encoding;

    late int length;
    if (value is Buffer) {
      length = value.length;
    } else {
      value = value.toString();
      length = Buffer.byteLength(value, encoding);
    }

    // Length of all chunks.
    // this.writeUInt64LE(length);
    // unknown seems to work better here - might revisit later.
    writeBuffer(UNKNOWN_PLP_LEN);

    // In the UNKNOWN_PLP_LEN case, the data is represented as a series of zero or more chunks.
    if (length > 0) {
      // One chunk.
      writeUInt32LE(length);
      if (value is Buffer) {
        writeBuffer(value);
      } else {
        makeRoomFor(length);
        buffer.write(value,
            offset: position, encoding: encoding == '' ? 'utf-8' : encoding);
        position += length;
      }
    }
    writeUInt32LE(0);
  }

  void writeMoney(int value) {
    writeInt32LE((value * SHIFT_RIGHT_32).floor());
    writeInt32LE(value & -1);
  }
}
