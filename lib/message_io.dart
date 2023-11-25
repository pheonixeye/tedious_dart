import 'dart:async';
import 'dart:typed_data';

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/incoming_message_stream.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/outgoing_message_stream.dart';

import 'package:socket_io_client/socket_io_client.dart';

class MessageIO extends EventEmitter {
  final Debug debug;
  final Socket socket;
  // ignore: unused_field
  final int _packetSize;

  final bool tlsNegotiationComplete;

  final IncomingMessageStream _incomingMessageStream;
  final OutgoingMessageStream outgoingMessageStream;

  // SecurePair? securePair;

  late StreamIterator<Message> incomingMessageIterator;

  MessageIO(this.socket, this._packetSize, this.debug)
      : _incomingMessageStream = IncomingMessageStream(debug),
        outgoingMessageStream =
            OutgoingMessageStream(debug, packetSize: _packetSize),
        tlsNegotiationComplete = false,
        super() {
    console.log(['defined MessageIo class']);

    console.log(['step 1']);

    incomingMessageIterator = StreamIterator(_incomingMessageStream.bind(
        _incomingMessageStream.asyncIterator.transform(BufferFromUnit8List())));

    console.log(['step 2']);

    // socket.pipe(_incomingMessageStream.controller.sink);
    socket.on(
        'connect', (data) => data.pipe(_incomingMessageStream.controller));

    console.log(['step 3']);

    outgoingMessageStream.controller.pipe(SocketConsumer(socket: socket));

    console.log(['step 4']);
  }

  int packetSize(List<int> args) {
    if (args.isNotEmpty) {
      var packetSize = args[0];
      debug.log('Packet size changed from '
          '${outgoingMessageStream.packetSize}'
          ' to '
          '$packetSize');
      outgoingMessageStream.packetSize = packetSize;
    }

    //!socket.setMaxSendFragments is not implemented in dart;
    //! affects latency only ?? TODO: check if working
    // if (this.securePair != null) {
    //   this
    //       .securePair!
    //       .clearText
    //       .setMaxSendFragment(this.outgoingMessageStream!.packetSize);
    // }

    return outgoingMessageStream.packetSize;
  }

  // startTls(SecurityContext credentialsDetails, String hostname, int port,
  //     bool trustServerCertificate) {
  //   // if (!credentialsDetails.maxVersion ||
  //   //     !['TLSv1.2', 'TLSv1.1', 'TLSv1']
  //   //         .includes(credentialsDetails.maxVersion)) {
  //   //   credentialsDetails.maxVersion = 'TLSv1.2';
  //   // }

  //   final secureContext = SecurityContext.defaultContext
  //     ..allowLegacyUnsafeRenegotiation = true;
  //   // tls.createSecureContext(credentialsDetails);

  //   return Future<void>(() async {
  //     final duplexpair = DuplexPair(
  //       socket1: await SecureSocket.connect(
  //         hostname,
  //         port,
  //         context: secureContext,
  //       ),
  //     );
  //     final securePair = this.securePair = SecurePair(
  //       cleartext: duplexpair.socket1!,
  //       encrypted: duplexpair.socket2,
  //     );
  //     final _socket = securePair.cleartext;
  //     // final controller = StreamController();
  //     // controller.addStream(_socket);
  //     final StreamSubscription<Uint8List> _subscription =
  //         _socket.listen((event) {});
  //     final consumer = SocketConsumer(_socket);
  //     // this.outgoingMessageStream!.unpipe(this.socket);
  //     // this.socket.unpipe(this.incomingMessageStream);

  //     _subscription.onData((data) async {
  //       this.socket.pipe(consumer);
  //       securePair.encrypted!.pipe(consumer);

  //       securePair.cleartext.pipe(_incomingMessageStream!);
  //       this
  //           .outgoingMessageStream!
  //           //TODO: wrong type
  //           .pipe(securePair.cleartext as StreamConsumer<Message?>);

  //       this.tlsNegotiationComplete = true;

  //       final message =
  //           Message(type: PACKETTYPE['PRELOGIN']!, resetConnection: false);

  //       dynamic chunk;
  //       while (chunk == await securePair.encrypted!.first) {
  //         message.controller.add(chunk);
  //       }
  //       this.outgoingMessageStream!.write(message, '', (e) {});
  //       message.controller.close();

  //       this.readMessage().then((response) async {
  //         // Setup readable handler for the next round of handshaking.
  //         // If we encounter a `secureConnect` on the cleartext side
  //         // of the secure pair, the `readable` handler is cleared
  //         // and no further handshake handling will happen.

  //         await for (var data in response) {
  //           // We feed the server's handshake response back into the
  //           // encrypted end of the secure pair.
  //           securePair.encrypted!.write(data.buffer);
  //         }
  //       }).catchError((e) {
  //         securePair.cleartext.close();
  //         securePair.encrypted!.close();
  //         throw e;
  //       });
  //     });

  //     _subscription.onError((e) {});

  //     // void onError(Error? err) {
  //     //   securePair.encrypted.removeListener('readable', onReadable);
  //     //   securePair.cleartext.removeListener('error', onError);
  //     //   securePair.cleartext.removeListener('secureConnect', onSecureConnect);

  //     //   securePair.cleartext.destroy();
  //     //   securePair.encrypted.destroy();

  //     //   reject(err);
  //     // }

  //     // void onReadable() {
  //     //   // When there is handshake data on the encryped stream of the secure pair,
  //     //   // we wrap it into a `PRELOGIN` message and send it to the server.
  //     //   //
  //     //   // For each `PRELOGIN` message we sent we get back exactly one response message
  //     //   // that contains the server's handshake response data.

  //     // }

  //     // securePair.cleartext.once('error', onError);
  //     // securePair.cleartext.once('secureConnect', onSecureConnect);
  //     // securePair.encrypted.once('readable', onReadable);
  //   });
  // }

  // todo listen for 'drain' event when socket.write returns false.
  // todo implement incomplete request cancelation (2.2.1.6)

  Future<Message> sendMessage(int packetType,
      {Buffer? data, bool? resetConnection}) async {
    console.log(['MessageIo.sendMessage();']);

    final message = Message(
      type: packetType,
      resetConnection: resetConnection,
    );

    message.controller.add(data!);
    message.controller.close();
    outgoingMessageStream.write(message, 'utf-8', ([error]) {});
    return message;
  }

  Future<Message> readMessage() async {
    console.log(['MessageIo.readMessage();']);
    final result = await incomingMessageIterator.moveNext();
    if (result) {
      return incomingMessageIterator.current;
    } else {
      throw ArgumentError('unexpected end of message stream');
    }
  }
}

class BufferFromUnit8List extends StreamTransformerBase<Uint8List, Buffer> {
  @override
  Stream<Buffer> bind(Stream<Uint8List> stream) {
    return stream
        .asBroadcastStream()
        .map((event) => Buffer.from(event))
        .asBroadcastStream();
  }
}

class Uint8ListFromBuffer extends StreamTransformerBase<Buffer, Uint8List> {
  @override
  Stream<Uint8List> bind(Stream<Buffer> stream) {
    return stream
        .asBroadcastStream()
        .map((event) => event.buffer)
        .asBroadcastStream();
  }
}

class IntListFromBuffer extends StreamTransformerBase<Buffer, List<int>> {
  @override
  Stream<List<int>> bind(Stream<Buffer> stream) {
    return stream
        .asBroadcastStream()
        .map((event) => event.buffer.toList())
        .asBroadcastStream();
  }
}

class SocketConsumer<Buffer> implements StreamConsumer<Buffer> {
  final Socket socket;

  SocketConsumer({required this.socket});
  @override
  Future addStream(Stream<Buffer> stream) {
    return Future.value(stream);
  }

  @override
  Future close() {
    return Future.value(socket.close());
  }
}
