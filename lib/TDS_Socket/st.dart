import 'package:tedious_dart/models/logger_stacktrace.dart';

abstract class TdsSocketState {
  const TdsSocketState();
}

class TdsSocketConnecting extends TdsSocketState {
  const TdsSocketConnecting({
    String? host,
    int? port,
  })  : host = host ?? 'localhost',
        port = port ?? 1433,
        super();
  final String host;
  final int port;
}

class TdsSocketConnected extends TdsSocketState {
  const TdsSocketConnected() : super();
}

class TdsSocketNotConnected extends TdsSocketState {
  const TdsSocketNotConnected() : super();
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
  TdsSocketReading() : super() {
    console.log(['Socket is Reading...']);
  }
}
