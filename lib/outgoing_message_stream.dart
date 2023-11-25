import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/packet.dart';
import 'package:buffer_list/buffer_list.dart';

class OutgoingMessageStream {
  int packetSize;
  final Debug debug;
  final BufferList bl;

  Message? currentMessage;

  final PublishSubject<Buffer?> controller;

  OutgoingMessageStream(this.debug, {required this.packetSize})
      : controller = PublishSubject<Buffer?>(),
        bl = BufferList() {
    // When the writable side is ended, push `null`
    // to also end the readable side.

    controller.doOnDone(() {
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
    currentMessage?.controller.listen((value) {}).onData((Buffer data) async {
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
        final lastE = await controller.last;
        if (lastE != packet.buffer) {
          message.controller.listen((value) {}).pause();
        }
      }
    });

    currentMessage?.controller.listen((value) {}).onDone(() {
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
      currentMessage!.controller.listen((value) {}).resume();
    }
  }
}
