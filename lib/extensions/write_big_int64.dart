// ignore_for_file: unnecessary_this

import 'package:node_interop/buffer.dart';

extension WriteBigInt64 on Buffer {
  external int writeBigInt64BE(num value, num offset, [bool noAssert]);
  external int writeBigInt64LE(num value, num offset, [bool noAssert]);
  external int writeBigUInt64BE(num value, num offset, [bool noAssert]);
  external int writeBigUint64BE(num value, num offset, [bool noAssert]);
  external int writeBigUInt64LE(num value, num offset, [bool noAssert]);
  external int writeBigUint64LE(num value, num offset, [bool noAssert]);
}

extension ReadBigInt64 on Buffer {
  external num readBigUInt64BE(num offset, [bool noAssert = false]);
  external num readBigUint64BE(num offset, [bool noAssert = false]);
  external num readBigUInt64LE(num offset, [bool noAssert = false]);
  external num readBigUint64LE(num offset, [bool noAssert = false]);
  external num readBigInt64BE(num offset, [bool noAssert = false]);
  external num readBigInt64LE(num offset, [bool noAssert = false]);
}
