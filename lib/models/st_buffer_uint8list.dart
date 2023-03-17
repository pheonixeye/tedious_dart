import 'dart:async';
import 'dart:typed_data';

import 'package:magic_buffer_copy/magic_buffer.dart';

class BufferUint8ListTransformer
    extends StreamTransformerBase<Buffer, Uint8List> {
  @override
  Stream<Uint8List> bind(Stream<Buffer> stream) {
    return stream.map((event) => event.buffer);
  }
}

class Uint8ListBufferTransformer
    extends StreamTransformerBase<Uint8List, Buffer> {
  @override
  Stream<Buffer> bind(Stream<Uint8List> stream) {
    return stream.map((event) => Buffer(event));
  }
}
