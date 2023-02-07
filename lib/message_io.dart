// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/incoming_message_stream.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/models/duplex.dart';
import 'package:tedious_dart/outgoing_message_stream.dart';

//!manufactured class
class SecurePair {
  SecureSocket clearText;
  Duplex encrypted;

  SecurePair({
    required this.clearText,
    required this.encrypted,
  });
}

class MessageIO extends EventEmitter {
  Debug debug;
  Socket socket;

  late bool? tlsNegotiationComplete;

  IncomingMessageStream? _incomingMessageStream;
  OutgoingMessageStream? outgoingMessageStream;

  SecurePair? securePair;

  late StreamIterator<Message> incomingMessageIterator;

  MessageIO(this.socket, int packetSize, this.debug) : super() {
    socket = socket;
    debug = debug;

    tlsNegotiationComplete = false;

    _incomingMessageStream = IncomingMessageStream(debug);
    incomingMessageIterator =
        _incomingMessageStream!.bl; //TODO: definitely wrong

    outgoingMessageStream =
        OutgoingMessageStream(debug, packetSize: packetSize);

    socket.pipe(_incomingMessageStream);
    outgoingMessageStream!.pipe(socket);
  }

  packetSize(List<int> args) {
    if (args.isNotEmpty) {
      var packetSize = args[0];
      this.debug.log('Packet size changed from '
          '${this.outgoingMessageStream!.packetSize}'
          ' to '
          '$packetSize');
      this.outgoingMessageStream!.packetSize = packetSize;
    }

    //!socket.setMaxSendFragments is not implemented in dart;
    //! affects latency only ?? TODO: check if working
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

  sendMessage(int packetType, {Buffer? data, bool? resetConnection}) async {
    final message =
        Message(type: packetType, resetConnection: resetConnection!);
    await message.drain();
    this.outgoingMessageStream!.write(message, 'utf-8', ([error]) {});
    return message;
  }

  Future<Message> readMessage() async {
    var result = this.incomingMessageIterator;

    if (!await result.moveNext()) {
      throw ArgumentError('unexpected end of message stream');
    }
    return result.current;
  }
}
