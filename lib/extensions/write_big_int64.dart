// ignore_for_file: unnecessary_this

import 'package:node_interop/buffer.dart';

extension WriteBigInt64 on Buffer {
  int writeBigInt64LE(num value, int offset, [bool noAssert = false]) {
    return this.fill(value, offset).length;
  }

  int writeBigUInt64LE(num value, int offset, [bool noAssert = false]) {
    return this.fill(value, offset).length;
  }
}
