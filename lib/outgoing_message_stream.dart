// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/node/buffer_list.dart';
import 'package:tedious_dart/packet.dart';

class OutgoingMessageStream implements StreamController<Message?> {
  int packetSize;
  Debug debug;
  dynamic bl;

  Message? currentMessage;

  OutgoingMessageStream(this.debug, {required this.packetSize}) {
    this.packetSize = packetSize;
    this.debug = debug;
    this.bl = BufferList([]);

    // When the writable side is ended, push `null`
    // to also end the readable side.

    this.stream.listen(
      (event) {},
      onDone: () {
        this.add(null);
      },
    );
  }

  write(
    Message message,
    String encoding,
    void Function([Error? error]) callback,
  ) {
    var length = this.packetSize - HEADER_LENGTH;
    var packetNumber = 0;

    this.currentMessage = message;
    this.currentMessage!.onData((Buffer data) async {
      if (message.ignore!) {
        return;
      }
      this.bl.append(data);

      while (this.bl.length > length) {
        var data = this.bl.slice(0, length);
        this.bl.consume(length);

        //  Get rid of creating `Packet` instances here.
        var packet = Packet(message.type);
        packet.packetId(packetNumber += 1);
        packet.resetConnection(message.resetConnection);
        packet.addData(data);

        this.debug.packet(Direction.Sent, packet);
        this.debug.data(packet);

        if (await this.stream.contains(packet.buffer) == false) {
          message.pause();
        }
      }
    });

    this.currentMessage!.onDone(() {
      var data = this.bl.slice();
      this.bl.consume(data.length);

      //  Get rid of creating `Packet` instances here.
      var packet = Packet(message.type);
      packet.packetId(packetNumber += 1);
      packet.resetConnection(message.resetConnection);
      packet.last(true);
      packet.ignore(message.ignore!);
      packet.addData(data);

      this.debug.packet(Direction.Sent, packet);
      this.debug.data(packet);

      this.add(packet.buffer);

      this.currentMessage = null;

      callback();
    });
  }

  read(int size) {
    // If we do have a message, resume it and get data flowing.
    // Otherwise, there is nothing to do.
    if (this.currentMessage != null) {
      this.currentMessage!.resume();
    }
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
    this.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    this.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream source, {bool? cancelOnError}) async {
    await this.addStream(source, cancelOnError: cancelOnError);
  }

  @override
  Future close() async {
    await this.close();
  }

  @override
  Future get done async => await this.done;

  @override
  bool get hasListener => throw UnimplementedError();

  @override
  bool get isClosed => throw UnimplementedError();

  @override
  bool get isPaused => throw UnimplementedError();

  @override
  StreamSink<Message?> get sink => this.sink;

  @override
  Stream<Message?> get stream => this.stream;
}
