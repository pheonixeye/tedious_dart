// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/node/buffer_list.dart';
import 'package:tedious_dart/packet.dart';

class OutgoingMessageStream extends Stream<Message?> {
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

    this.listen(
      (event) {},
      onDone: () {
        _controller.sink.add(null);
      },
    );

    _controller.addStream(this);
  }

  final _controller = StreamController.broadcast();

  write(
    Message message,
    String encoding,
    void Function([Error? error]) callback,
  ) {
    var length = this.packetSize - HEADER_LENGTH;
    var packetNumber = 0;

    this.currentMessage = message;
    this.currentMessage!.listen(
      (Buffer data) async {
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

          if (await this.contains(packet.buffer) == false) {
            message.pause();
          }
        }
      },
      onDone: () {
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

        this._controller.sink.add(packet.buffer);

        this.currentMessage = null;

        callback();
      },
    );
  }

  read(int size) {
    // If we do have a message, resume it and get data flowing.
    // Otherwise, there is nothing to do.
    if (this.currentMessage != null) {
      this.currentMessage!.resume();
    }
  }

  @override
  StreamSubscription<Message?> listen(void Function(Message? event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return this.listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}
