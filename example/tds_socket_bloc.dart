import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/TDS_Socket/ev.dart';
import 'package:tedious_dart/TDS_Socket/tds_socket.dart';
import 'package:tedious_dart/packet.dart';
import 'package:tedious_dart/prelogin_payload.dart';

void main(List<String> args) async {
  final socket = TdsSocket();
  socket.add(ConnectEvent());

  final Packet preLoginPacket =
      applyPacketHeader(PACKETTYPE['PRELOGIN']!, preloginPayload.data);

  socket.add(WriteEvent(preLoginPacket.buffer.buffer));
  socket.add(ReadEvent());
  // socket.add(DisconnectEvent());
}

final preloginPayload = PreloginPayload(
  PreloginPayloadOptions(
    encrypt: false,
    version: PreloginPayloadVersion(
      major: 0,
      minor: 0,
      build: 0,
      subbuild: 0,
    ),
  ),
);

Packet applyPacketHeader(
    int type, //eg: PACKETTYPE['PRELOGIN']
    Buffer data,
    [bool isLast = true]) {
  final packet = Packet(type);
  int packetId = 0;
  // packetId++;
  packet.packetId(packetId);
  packet.last(isLast);
  packet.ignore(false);
  packet.addData(data);
  return packet;
}
