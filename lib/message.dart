import 'dart:async';

import 'package:magic_buffer_copy/magic_buffer.dart';

class Message extends Stream<Buffer> {
  int type;
  bool resetConnection;
  bool ignore;
  final StreamController<Buffer> controller;
  Message({
    required this.type,
    bool? resetConnection,
    bool? ignore,
  })  : controller = StreamController<Buffer>.broadcast(),
        resetConnection = resetConnection ?? false,
        ignore = ignore ?? false,
        super() {
    controller.sink.addStream(this);
  }
  StreamSubscription<Buffer> get subscription => listen((event) {});

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
