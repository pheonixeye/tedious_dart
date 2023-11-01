import 'dart:async';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/packet.dart';
import 'package:buffer_list/buffer_list.dart';

class OutgoingMessageStream extends Stream<Buffer?> {
  int packetSize;
  final Debug debug;
  final BufferList bl;

  Message? currentMessage;

  final StreamController<Buffer?> controller;
  StreamSubscription<Buffer?> get subscription =>
      controller.stream.asBroadcastStream().listen((event) {});

  OutgoingMessageStream(this.debug, {required this.packetSize})
      : controller = StreamController<Buffer?>.broadcast(),
        bl = BufferList() {
    controller.sink.addStream(this);

    // When the writable side is ended, push `null`
    // to also end the readable side.
    subscription.onDone(() {
      controller.add(null);
    });
  }

  void write(
    Message message,
    String? encoding,
    void Function([Error? error]) callback,
  ) {
    final int length = packetSize - HEADER_LENGTH;
    int packetNumber = 0;

    currentMessage = message;
    currentMessage?.subscription.onData((Buffer data) async {
      if (message.ignore == true) {
        return;
      }

      bl.append(data);

      while (bl.length > length) {
        final data = bl.slice(0, length);
        bl.consume(length);

        // todo: Get rid of creating `Packet` instances here.
        final packet = Packet(message.type);
        packet.packetId(packetNumber += 1);
        packet.resetConnection(message.resetConnection);
        packet.addData(data);

        debug.packet(Direction.Sent, packet);
        debug.data(packet);
        final lastE = await last;
        if (lastE != packet.buffer) {
          message.subscription.pause();
        }
      }
    });

    currentMessage?.subscription.onDone(() {
      final data = bl.slice(0, 0) as Buffer;
      bl.consume(data.length);

      // todo: Get rid of creating `Packet` instances here.
      final packet = Packet(message.type);
      packet.packetId(packetNumber += 1);
      packet.resetConnection(message.resetConnection);
      packet.last(true);
      packet.ignore(message.ignore);
      packet.addData(data);

      debug.packet(Direction.Sent, packet);
      debug.data(packet);

      controller.add(packet.buffer);

      currentMessage = null;

      callback();
    });
  }

  void read(int size) {
    // If we do have a message, resume it and get data flowing.
    // Otherwise, there is nothing to do.
    if (currentMessage != null) {
      currentMessage!.subscription.resume();
    }
  }

  @override
  StreamSubscription<Buffer?> listen(void Function(Buffer? event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return controller.stream.asBroadcastStream().listen(onData,
        onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  }
}
