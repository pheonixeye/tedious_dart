// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
// import 'package:tedious_dart/node/buffer_list.dart';
import 'package:tedious_dart/packet.dart';

class OutgoingMessageStream extends Stream<Buffer?> {
  int packetSize;
  Debug debug;
  dynamic bl;

  Message? currentMessage;

  late final StreamController<Buffer?> controller;
  StreamSubscription<Buffer?> get subscription =>
      controller.stream.asBroadcastStream().listen((event) {});

  OutgoingMessageStream(this.debug, {required this.packetSize}) {
    this.packetSize = packetSize;
    this.debug = debug;
    this.bl = List<Buffer>.empty();
    // BufferList([]);
    controller = StreamController<Buffer?>.broadcast();
    controller.sink.addStream(this);

    // When the writable side is ended, push `null`
    // to also end the readable side.
    subscription.onDone(() {
      controller.add(null);
    });
  }

  write(
    Message message,
    String? encoding,
    void Function(Error? error) callback,
  ) {
    var length = this.packetSize - HEADER_LENGTH;
    var packetNumber = 0;

    this.currentMessage = message;
    this.currentMessage!.subscription.onData((data) async {
      if (message.ignore == true) {
        return;
      }
      this.bl.append(data);

      this.bl.append(data);

      while (this.bl.length > length) {
        final data = this.bl.slice(0, length);
        this.bl.consume(length);

        // TODO: Get rid of creating `Packet` instances here.
        final packet = Packet(message.type);
        packet.packetId(packetNumber += 1);
        packet.resetConnection(message.resetConnection);
        packet.addData(data);

        this.debug.packet(Direction.Sent, packet);
        this.debug.data(packet);

        if (await any((d) => d == packet.buffer) == false) {
          message.subscription.pause();
        }
      }
    });

    this.currentMessage!.subscription.onDone(() {
      final data = this.bl.slice();
      this.bl.consume(data.length);

      // TODO: Get rid of creating `Packet` instances here.
      final packet = Packet(message.type);
      packet.packetId(packetNumber += 1);
      packet.resetConnection(message.resetConnection);
      packet.last(true);
      packet.ignore(message.ignore!);
      packet.addData(data);

      this.debug.packet(Direction.Sent, packet);
      this.debug.data(packet);

      this.controller.add(packet.buffer);

      this.currentMessage = null;

      Function.apply(callback, []);
    });
  }

  read(int size) {
    // If we do have a message, resume it and get data flowing.
    // Otherwise, there is nothing to do.
    if (this.currentMessage != null) {
      this.currentMessage!.subscription.resume();
    }
  }

  @override
  StreamSubscription<Buffer?> listen(void Function(Buffer? event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return controller.stream.listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }
}
