// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/node/buffer_list.dart';
import 'package:tedious_dart/packet.dart';

class IncomingMessageStream extends Stream<Buffer> {
  Debug debug;
  dynamic bl;
  Message? currentMessage;

  IncomingMessageStream(this.debug) : super() {
    currentMessage = null;
    bl = BufferList([]);
  }

  pause() {
    if (this.currentMessage != null) {
      this.currentMessage!.pause();
    }

    return this;
  }

  resume() {
    if (this.currentMessage != null) {
      this.currentMessage!.resume();
    }

    return this;
  }

  processBufferedData(void Function([ConnectionError? error])? callback) async {
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
          this.add(message);
        }

        if (packet.isLast()) {
          // Wait until the current message was fully processed before we
          // continue processing any remaining messages.
          message.onDone(() {
            this.currentMessage = null;
            this.processBufferedData(callback);
          });
          message.cancel();
          // message.once('end', () {});
          // message.end(packet.data());
          return;
        } else if (await message.asFuture(packet.data())) {
          // If too much data is buffering up in the
          // current message, wait for it to drain.
          this.processBufferedData(callback);
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
    callback!();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<Buffer, S> streamTransformer) {
    return super.transform(streamTransformer);
  }

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }
}
