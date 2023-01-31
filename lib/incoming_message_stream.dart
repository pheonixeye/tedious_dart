// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/node/buffer_list.dart';
import 'package:tedious_dart/packet.dart';

class IncomingMessageStream extends StreamConsumer<Message> {
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

  transform(
    Buffer chunk,
    String encoding,
    void Function([ConnectionError? error])? callback,
  ) {
    this.bl.append(chunk);
    this.processBufferedData(callback);
  }

  @override
  FutureOr<void> Function()? onCancel;

  @override
  void Function()? onListen;

  @override
  void Function()? onPause;

  @override
  void Function()? onResume;

  @override
  void add(event) {
    // TODO: implement add
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // TODO: implement addError
  }

  @override
  Future addStream(Stream source, {bool? cancelOnError}) {
    // TODO: implement addStream
    throw UnimplementedError();
  }

  @override
  Future close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  // TODO: implement done
  Future get done => throw UnimplementedError();

  @override
  // TODO: implement hasListener
  bool get hasListener => throw UnimplementedError();

  @override
  // TODO: implement isClosed
  bool get isClosed => throw UnimplementedError();

  @override
  // TODO: implement isPaused
  bool get isPaused => throw UnimplementedError();

  @override
  // TODO: implement sink
  StreamSink get sink => throw UnimplementedError();

  @override
  // TODO: implement stream
  Stream get stream => throw UnimplementedError();
}
