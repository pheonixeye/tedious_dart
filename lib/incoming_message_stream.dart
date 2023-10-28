// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:typed_data';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/models/errors.dart';
// import 'package:tedious_dart/node/buffer_list.dart';
import 'package:tedious_dart/packet.dart';

class IncomingMessageStream extends Stream<Buffer>
    implements StreamConsumer<Uint8List> {
  Debug debug;
  dynamic bl;
  Message? currentMessage;
  late final StreamController<Buffer> controller;

  IncomingMessageStream(this.debug) : super() {
    currentMessage = null;
    //TODO: re-implement bufferList class;
    bl = List<Buffer>.empty();
    controller = StreamController<Buffer>.broadcast();
    // controller.sink.addStream(this);

    // BufferList([]);
  }
  pause() {
    // super.pause();
    if (this.currentMessage != null) {
      this.currentMessage!.controller.stream.listen((event) {}).pause();
    }
    return this;
  }

  resume() {
    // super.resume();
    if (this.currentMessage != null) {
      this.currentMessage!.controller.stream.listen((event) {}).resume();
    }
    return this;
  }

  processBufferedData(void Function(ConnectionError? error)? callback) async {
    // The packet header is always 8 bytes of length.
    while (this.bl.length >= HEADER_LENGTH) {
      // Get the full packet length
      var length = this.bl.readUInt16BE(2);
      if (length < HEADER_LENGTH) {
        return callback!(ConnectionError('Unable to process incoming packet'));
      }

      if (this.bl.length >= length) {
        var data = this.bl.slice(0, length);
        this.bl.consume(length);

        // TODO: Get rid of creating `Packet` instances here.
        final packet = Packet(data);
        this.debug.packet(Direction.Received, packet);
        this.debug.data(packet);

        var message = this.currentMessage;
        if (message == null) {
          this.currentMessage = message = Message(
            type: packet.type(),
            resetConnection: false,
          );
          controller.sink.add(await message.controller.stream.first);
          // this.add(message);
        }

        if (packet.isLast()) {
          // Wait until the current message was fully processed before we
          // continue processing any remaining messages.
          message.subscription.onDone(() {
            this.currentMessage = null;
            this.processBufferedData(callback);
          });
          message.controller.add(packet.data());
          message.controller.close();
          return;
        } else if (await message.controller.sink.done) {
          //!message.write(packet.data())
          // If too much data is buffering up in the
          // current message, wait for it to drain.
          message.drain(this.processBufferedData(callback));
          // message.once('drain', () {
          // });
          return;
        }
      } else {
        break;
      }
    }

    // Not enough data to read the next packet. Stop here and wait for
    // the next call to `_transform`.
    Function.apply(callback!, []);
  }

  transform_(Buffer chunk, String? _encoding, void Function() callback) {
    this.bl.append(chunk);
    this.processBufferedData(Function.apply(callback, []));
  }

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return controller.stream.asBroadcastStream().listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }

  @override
  Future addStream(Stream<Uint8List> stream) {
    final streamTransformer =
        StreamTransformer<Uint8List, Buffer>.fromBind((p0) {
      return p0.asBroadcastStream().map((event) => Buffer.from(event));
    });
    return controller.addStream(stream.transform<Buffer>(streamTransformer));
  }

  @override
  Future close() {
    return controller.close();
  }
}
