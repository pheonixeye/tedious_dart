// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_this, library_prefixes

import 'dart:typed_data';
import 'dart:math' as Math;
import 'package:tedious_dart/types/buffer/buffer_encoding.dart';

const SHIFT_LEFT_32 = (1 << 16) * (1 << 16);
const SHIFT_RIGHT_32 = 1 / SHIFT_LEFT_32;
final UNKNOWN_PLP_LEN =
    Uint8List.fromList([0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
final ZERO_LENGTH_BUFFER = Uint8List.fromList([0]);

class WritableTrackingBuffer {
  num initialSize;
  String? encoding;
  bool? doubleSizeGrowth;
  Uint8List? buffer;
  Uint8List? compositeBuffer;
  num position = 0;

  WritableTrackingBuffer(
    this.initialSize,
    this.encoding,
    this.doubleSizeGrowth,
  ) {
    initialSize = initialSize;
    encoding = encoding ?? BufferEncoding.ucs2.type;
    doubleSizeGrowth = doubleSizeGrowth ?? false;
    buffer = buffer!.sublist(initialSize.toInt(), 0);
    compositeBuffer = ZERO_LENGTH_BUFFER;
    position = 0;
  }

  get data {
    this.newBuffer(0);
    return this.compositeBuffer;
  }

  copyFrom(Uint8List buffer) {
    var length = buffer.length;
    this.makeRoomFor(length);
    buffer.insertAll(this.position.toInt(), this.buffer as Iterable<int>);
    this.position += length;
  }

  makeRoomFor(num requiredLength) {
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

  newBuffer(num size) {
    final buffer = this.buffer!.sublist(0, position.toInt());
    this.compositeBuffer = buffer.followedBy(buffer) as Uint8List;
    this.buffer = size == 0 ? ZERO_LENGTH_BUFFER : Uint8List.fromList([0]);
    this.position = 0;
  }

  writeUInt8(num value) {
    const length = 1;
    this.makeRoomFor(length);
    this.buffer!.insert(this.position.toInt(), value.toInt());
    this.position += length;
  }
}
