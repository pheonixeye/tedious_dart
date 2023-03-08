import 'dart:async';

import 'package:magic_buffer/magic_buffer.dart';

class Message extends Stream<Buffer> {
  int type;
  bool resetConnection;
  bool? ignore;
  late final StreamController controller;
  late final StreamSubscription<Buffer> subscription;
  Message({
    required this.type,
    required this.resetConnection,
    this.ignore = false,
  }) : super() {
    controller.addStream(this);
    subscription = listen((event) {});
  }

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return subscription;
  }
}
