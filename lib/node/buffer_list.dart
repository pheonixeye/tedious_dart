@JS()
library node_interop.events;

import 'package:node_interop/buffer.dart';
import 'package:js/js.dart';

@JS()
@anonymous
abstract class _BufferList {
  dynamic initialData;

  _BufferList();

  external int get length;
  external _BufferList append(dynamic buffer);
  external dynamic get(int index);
  external Buffer slice(int? start, int? end);
  external _BufferList shallowSlice(int? start, int? end);
  external Buffer copy(
      {Buffer dest, int? destStart, int? srcStart, int? srcEnd});
  external _BufferList duplicate();
  external void consume(int? bytes);
  external String toStringDeep(String? encoding, int? start, int? end);
  external int indexOf(dynamic value, int? byteOffset, String? encoding);
  external int readDoubleBE(int? offset);
  external int readDoubleLE(int? offset);
  external int readFloatBE(int? offset);
  external int readFloatLE(int? offset);
  external int readInt32BE(int? offset);
  external int readInt32LE(int? offset);
  external int readUInt32BE(int? offset);
  external int readUInt32LE(int? offset);
  external int readInt16BE(int? offset);
  external int readInt16LE(int? offset);
  external int readUInt16BE(int? offset);
  external int readUInt16LE(int? offset);
  external int readInt8(int? offset);
  external int readUInt8(int? offset);
  external int readIntBE(int? offset);
  external int readIntLE(int? offset);
  external int readUIntBE(int? offset);
  external int readUIntLE(int? offset);

  external bool isBufferList(dynamic other);
}

class BufferList extends _BufferList {
  @override
  dynamic initialData;

  BufferList(this.initialData);
}
