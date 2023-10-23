import 'dart:async';

final controller = StreamController();

testit() {
  final a = controller.stream.listen((event) {});

  a.pause();
}
