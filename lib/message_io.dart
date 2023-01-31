// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';

// import 'package:node_interop/events.dart';
// import 'package:node_interop/net.dart';
// import 'package:node_interop/stream.dart';
import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/incoming_message_stream.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/outgoing_message_stream.dart';

class SecurePair {
  Socket clearText;
  Stream encrypted;

  SecurePair({
    required this.clearText,
    required this.encrypted,
  });
}

class MessageIO extends EventSink {
  Debug debug;
  Socket socket;

  late bool tlsNegotiationComplete;

  IncomingMessageStream? _incomingMessageStream;
  OutgoingMessageStream? outgoingMessageStream;

  late SecurePair? securePair;

  late Future<Iterator<Message>> incomingMessageIterator;

  MessageIO(this.socket, int packetSize, this.debug) : super() {
    socket = socket;
    debug = debug;

    tlsNegotiationComplete = false;

    _incomingMessageStream = IncomingMessageStream(debug);
    incomingMessageIterator =
        _incomingMessageStream!.bl; //TODO: definitely wrong

    outgoingMessageStream =
        OutgoingMessageStream(debug, packetSize: packetSize);

    socket.write(_incomingMessageStream);
    outgoingMessageStream!.addStream(socket);
  }

  @override
  void add(event) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  void close() {}

  packetSize(List<int> args) {
    if (args.isNotEmpty) {
      var packetSize = args[0];
      this.debug.log('Packet size changed from '
          '${this.outgoingMessageStream!.packetSize}'
          ' to '
          '$packetSize');
      this.outgoingMessageStream!.packetSize = packetSize;
    }

    // if (this.securePair != null) {
    //   this
    //       .securePair!
    //       .clearText
    //       .setMaxSendFragment(this.outgoingMessageStream!.packetSize);
    // }

    return this.outgoingMessageStream!.packetSize;
  }

  startTls() {
    //TODO:
  }

  // todo listen for 'drain' event when socket.write returns false.
  // todo implement incomplete request cancelation (2.2.1.6)

  sendMessage(int packetType, Buffer? data, bool? resetConnection) {
    final message =
        Message(type: packetType, resetConnection: resetConnection!);
    message.cancel();
    this.outgoingMessageStream!.write(message, 'utf-8', ([error]) {});
    return message;
  }

  Future<Message> readMessage() async {
    var result = await this.incomingMessageIterator;

    if (!result.moveNext()) {
      throw ArgumentError('unexpected end of message stream');
    }

    return result.current;
  }
}
