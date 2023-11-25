import 'package:tedious_dart/TDS_Socket/ev.dart';
import 'package:tedious_dart/TDS_Socket/tds_socket.dart';

void main(List<String> args) async {
  final socket = TdsSocket();
  socket.add(InitEvent());
  socket.add(WriteEvent([]));
}
