// ignore_for_file: unnecessary_this, constant_identifier_names

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:node_interop/util.dart';
import 'package:tedious_dart/packet.dart';

enum Direction {
  Received('Received'),
  Sent('Sent');

  const Direction(this.value);
  final String value;
}

class Debug extends EventEmitter {
  final DebugOptions options;
  final String indent;

  Debug({
    required this.options,
    this.indent = '  ',
  });

  data(Packet packet) {
    if (this.haveListeners() && this.options.data == true) {
      this.log(packet.dataToString(indent: this.indent));
    }
  }

  packet(Direction direction, Packet packet) {
    if (this.haveListeners() && this.options.packet == true) {
      this.log('');
      this.log(direction.value);
      this.log(packet.headerToString(indent: this.indent));
    }
  }

  payload(String Function() generatePayloadText) {
    if (this.haveListeners() && this.options.payload == true) {
      this.log(generatePayloadText());
    }
  }

  token(dynamic token) {
    if (this.haveListeners() && this.options.token == true) {
      this.log(
        util.inspect(
          token,
          {
            'showHidden': false,
            'depth': 5,
            'colors': true,
          },
        ),
      );
    }
  }

  haveListeners() {
    return this.listeners.isNotEmpty;
    // return this.listeners('debug').isNotEmpty;
  }

  log(String text) {
    this.emit('debug', text);
  }
}

class DebugOptions {
  final bool? data;
  final bool? payload;
  final bool? packet;
  final bool? token;

  const DebugOptions({
    this.data = false,
    this.payload = false,
    this.packet = false,
    this.token = false,
  });
}
