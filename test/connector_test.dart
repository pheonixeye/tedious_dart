import 'package:tedious_dart/connector.dart';
import 'package:tedious_dart/node/abort_controller.dart';
import 'package:test/test.dart';

void main() async {
  final signal = AbortSignal();
  final LocalConnectionOptions localConnectionOptions = LocalConnectionOptions(
    host: '127.0.0.1',
    port: 1433,
  );
  test('testing connectInSequence function', () {
    connectInSequence(
      localConnectionOptions,
      signal,
    ).listen((socket) {
      print(socket!.address);
      print(socket.port);
      print(socket.remoteAddress);
      print(socket.remotePort);
      print(socket.encoding);
    });
  });
  test('testing connectInParallel function', () {
    connectInParallel(
      localConnectionOptions,
      signal,
    ).listen((socket) {
      print(socket!.address);
      print(socket.port);
      print(socket.remoteAddress);
      print(socket.remotePort);
      print(socket.encoding);
    });
  });
}
