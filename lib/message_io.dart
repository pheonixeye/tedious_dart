// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:typed_data';

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/incoming_message_stream.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/models/duplex.dart';
// import 'package:tedious_dart/models/duplex.dart';
import 'package:tedious_dart/outgoing_message_stream.dart';
import 'package:tedious_dart/packet.dart';

//!manufactured class
class SecurePair {
  RawSecureSocket cleartext;
  RawSecureSocket? encrypted;

  SecurePair({
    required this.cleartext,
    this.encrypted,
  });
}

class MessageIO extends EventEmitter {
  final Debug debug;
  final Socket socket;
  int _packetSize;

  late bool? tlsNegotiationComplete;

  IncomingMessageStream? _incomingMessageStream;
  OutgoingMessageStream? outgoingMessageStream;

  SecurePair? securePair;

  late StreamIterator<Message> incomingMessageIterator;

  MessageIO(this.socket, this._packetSize, this.debug) : super() {
    tlsNegotiationComplete = false;

    _incomingMessageStream = IncomingMessageStream(debug);
    incomingMessageIterator = StreamIterator(_incomingMessageStream!);

    outgoingMessageStream =
        OutgoingMessageStream(debug, packetSize: _packetSize);

    socket.pipe(_incomingMessageStream!);
    //TODO: wrong type
    outgoingMessageStream?.pipe(socket as StreamConsumer<Message>);
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

  startTls(SecurityContext credentialsDetails, String hostname, int port,
      bool trustServerCertificate) {
    // if (!credentialsDetails.maxVersion ||
    //     !['TLSv1.2', 'TLSv1.1', 'TLSv1']
    //         .includes(credentialsDetails.maxVersion)) {
    //   credentialsDetails.maxVersion = 'TLSv1.2';
    // }

    final secureContext = SecurityContext.defaultContext
      ..allowLegacyUnsafeRenegotiation = true;
    // tls.createSecureContext(credentialsDetails);

    return Future<void>(() async {
      final duplexpair = DuplexPair(
        socket1: await RawSecureSocket.connect(
          hostname,
          port,
          context: secureContext,
        ),
      );
      final securePair = this.securePair = SecurePair(
        cleartext: duplexpair.socket1!,
        encrypted: duplexpair.socket2,
      );
      final _socket = securePair.cleartext;
      // final controller = StreamController();
      // controller.addStream(_socket);
      final StreamSubscription<Uint8List> _subscription =
          _socket.listen((event) {});
      final consumer = SocketConsumer(_socket);
      // this.outgoingMessageStream!.unpipe(this.socket);
      // this.socket.unpipe(this.incomingMessageStream);

      _subscription.onData((data) async {
        this.socket.pipe(consumer);
        securePair.encrypted!.pipe(consumer);

        securePair.cleartext.pipe(_incomingMessageStream!);
        this
            .outgoingMessageStream!
            //TODO: wrong type
            .pipe(securePair.cleartext as StreamConsumer<Message?>);

        this.tlsNegotiationComplete = true;

        final message =
            Message(type: PACKETTYPE['PRELOGIN']!, resetConnection: false);

        dynamic chunk;
        while (chunk == await securePair.encrypted!.first) {
          message.controller.add(chunk);
        }
        this.outgoingMessageStream!.write(message, '', (e) {});
        message.controller.close();

        this.readMessage().then((response) async {
          // Setup readable handler for the next round of handshaking.
          // If we encounter a `secureConnect` on the cleartext side
          // of the secure pair, the `readable` handler is cleared
          // and no further handshake handling will happen.

          await for (var data in response) {
            // We feed the server's handshake response back into the
            // encrypted end of the secure pair.
            securePair.encrypted!.write(data);
          }
        }).catchError((e) {
          securePair.cleartext.destroy();
          securePair.encrypted!.destroy();
          throw e;
        });
      });

      _subscription.onError((e) {});

      // void onError(Error? err) {
      //   securePair.encrypted.removeListener('readable', onReadable);
      //   securePair.cleartext.removeListener('error', onError);
      //   securePair.cleartext.removeListener('secureConnect', onSecureConnect);

      //   securePair.cleartext.destroy();
      //   securePair.encrypted.destroy();

      //   reject(err);
      // }

      // void onReadable() {
      //   // When there is handshake data on the encryped stream of the secure pair,
      //   // we wrap it into a `PRELOGIN` message and send it to the server.
      //   //
      //   // For each `PRELOGIN` message we sent we get back exactly one response message
      //   // that contains the server's handshake response data.

      // }

      // securePair.cleartext.once('error', onError);
      // securePair.cleartext.once('secureConnect', onSecureConnect);
      // securePair.encrypted.once('readable', onReadable);
    });
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

class SocketConsumer extends StreamConsumer<Uint8List> {
  late final SecureSocket socket;
  SocketConsumer(this.socket);
  @override
  Future addStream(Stream stream) async {
    this.addStream(socket);
  }

  @override
  Future close() async {
    this.close();
  }
}
