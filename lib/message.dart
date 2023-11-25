import 'dart:async';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:rxdart/rxdart.dart';

class Message extends PassthroughStream<Buffer> {
  int type;
  bool resetConnection;
  bool ignore;
  final PublishSubject<Buffer> controller;
  Message({
    required this.type,
    bool? resetConnection,
    bool? ignore,
  })  : controller = PublishSubject<Buffer>(),
        resetConnection = resetConnection ?? false,
        ignore = ignore ?? false,
        super() {
    bind(controller.stream);
  }
}

class PassthroughStream<T> extends StreamTransformerBase<T, T> {
  @override
  Stream<T> bind(Stream<T> stream) {
    return PublishSubject<T>();
  }
}
