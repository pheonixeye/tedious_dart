import 'dart:typed_data';

import 'package:tedious_dart/models/logger_stacktrace.dart';

abstract class TdsSocketState {
  const TdsSocketState();
}

class TdsSocketNotConnected extends TdsSocketState {
  TdsSocketNotConnected() : super() {
    console.log(["Socket Disconnected..."]);
  }
}

class TdsSocketConnecting extends TdsSocketState {
  const TdsSocketConnecting() : super();
}

class TdsSocketConnected extends TdsSocketState {
  const TdsSocketConnected() : super();
}

class TdsSocketError extends TdsSocketState {
  TdsSocketError(this.error) : super() {
    console.log([error.toString()]);
  }
  final Object error;
}

class TdsSocketWriting extends TdsSocketState {
  TdsSocketWriting() : super() {
    console.log(['Socket is Writing...']);
  }
}

class TdsSocketReading extends TdsSocketState {
  TdsSocketReading(this.data) : super() {
    console.log(['Socket is Reading...']);
    console.log(['$data']);
  }
  final Uint8List? data;
}
