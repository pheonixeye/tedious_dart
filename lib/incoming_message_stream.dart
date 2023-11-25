import 'dart:async';
import 'dart:typed_data';

import 'package:buffer_list/buffer_list.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/message_io.dart';
// import 'package:tedious_dart/message_io.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
// import 'package:tedious_dart/node/buffer_list.dart';
import 'package:tedious_dart/packet.dart';

///
///  IncomingMessageStream
///  Transform received TDS data into individual IncomingMessage streams.
///
class IncomingMessageStream extends StreamTransformerBase<Buffer, Message> {
  final Debug debug;
  final BufferList bl = BufferList();
  final PublishSubject<Uint8List> controller;
  Message? currentMessage;

  IncomingMessageStream(this.debug)
      : controller = PublishSubject<Uint8List>(),
        super() {
    console.log(['got to IncomingMessageStream();']);
  }

  Stream<Uint8List> get asyncIterator => controller.stream;

  pause() {
    console.log(['got to incomingMessageStream.pause();']);

    if (currentMessage != null) {
      currentMessage!.controller.stream
          .asBroadcastStream()
          .listen((event) {})
          .pause();
    }
    return this;
  }

  resume() {
    // super.resume();
    console.log(['got to incomingMessageStream.resume();']);

    if (currentMessage != null) {
      currentMessage!.controller.stream
          .asBroadcastStream()
          .listen((event) {})
          .resume();
    }
    return this;
  }

  Future<Message?> processBufferedData(
      [void Function(ConnectionError? error)? callback]) async {
    // The packet header is always 8 bytes of length.
    console.log(['got to incomingMessageStream.processBufferedData();']);

    while (bl.length >= HEADER_LENGTH) {
      // Get the full packet length
      int length = bl.readUInt16BE(2);
      if (length < HEADER_LENGTH) {
        callback!(ConnectionError('Unable to process incoming packet'));
      }

      if (bl.length >= length) {
        var data = bl.slice(0, length);
        bl.consume(length);

        // TODO: Get rid of creating `Packet` instances here.
        final packet = Packet(data);
        debug.packet(Direction.Received, packet);
        debug.data(packet);

        var message = currentMessage;
        if (message == null) {
          currentMessage = message = Message(
            type: packet.type(),
            resetConnection: false,
          );
          controller.add(await message.controller.stream
              .transform(Uint8ListFromBuffer())
              .first);
          // this.add(message);
        }

        if (packet.isLast()) {
          // Wait until the current message was fully processed before we
          // continue processing any remaining messages.
          message.controller.listen((value) {}).onDone(() {
            currentMessage = null;
            processBufferedData(callback);
          });
          message.controller.add(packet.data());
          message.controller.close();
          return null;
        } else if (message.controller.sink.done == true) {
          //!message.write(packet.data())
          // If too much data is buffering up in the
          // current message, wait for it to drain.
          message.controller.stream.drain(processBufferedData(callback));
          // message.once('drain', () {
          // });
          return null;
        }
      } else {
        break;
      }
    }

    // Not enough data to read the next packet. Stop here and wait for
    // the next call to `_transform`.
    // Function.apply(callback!, []);
    callback ?? callback!(null);
    return currentMessage;
  }

  transform_(Buffer chunk, String? _encoding, void Function() callback) {
    console.log(['got to incomingMessageStream.transform_();']);

    bl.append(chunk);
    processBufferedData(Function.apply(callback, []));
  }

  @override
  Stream<Message> bind(Stream<Buffer> stream) {
    return stream.asBroadcastStream().asyncMap((event) {
      bl.append(event);
      return processBufferedData() as FutureOr<Message>;
    });
  }

  // @override
  // Future addStream(Stream<Uint8List> stream) {
  //   console.log(['got to incomingMessageStream.addStream();']);
  //   return controller
  //       .addStream(stream.asBroadcastStream().asyncMap((event) async {
  //     console.log([
  //       'got to incomingMessageStream.addStream()=>controller.addStream();'
  //     ]);

  //     bl.append(event);
  //     final m = await processBufferedData();
  //     return Message(type: m!.type);
  //   }));
  // }

  // @override
  // Future close() {
  //   console.log(['got to incomingMessageStream.close();']);
  //   return controller.close();
  // }
}
