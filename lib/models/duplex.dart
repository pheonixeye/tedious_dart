import 'dart:async';

import 'package:events_emitter/emitters/event_emitter.dart';

class Duplex<T> extends EventEmitter {
  late final Stream<T> _stream;
  final StreamController<T> _controller = StreamController<T>.broadcast();
  late final StreamSink<T> _sink;

  Duplex() {
    _stream = _controller.stream;
    _sink = _controller.sink;
  }

  StreamController get controller => _controller;
  Stream get stream => _stream;
  StreamSink get sink => _sink;
}
