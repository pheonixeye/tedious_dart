import 'dart:io';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/packet.dart';
import 'package:tedious_dart/prelogin_payload.dart';

void main(List<String> args) async {
  final preSocket = RawSocket.connect('127.0.0.1', 1433);
  final socket = await preSocket;

  print(preloginPayload.toString());
  print(preloginPayload.data.buffer);
  final Packet preLoginPacket =
      applyPacketHeader(PACKETTYPE['PRELOGIN']!, preloginPayload.data);
  print(preLoginPacket.headerToString());
  print(preLoginPacket.dataToString());
  print(preLoginPacket.buffer.buffer);
  socket.write(preLoginPacket.buffer.buffer);
  await Future.delayed(duration);
  final received = socket.read();
  final receivedPacket = Packet(Buffer(received));
  print(receivedPacket.toString());
}

const duration = Duration(milliseconds: 100);

final preloginPayload = PreloginPayload(
  PreloginPayloadOptions(
    encrypt: true,
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
) {
  final packet = Packet(type);
  int packetId = 1;
  // packetId++;
  packet.packetId(packetId);
  packet.last(true);
  packet.addData(data);
  return packet;
}
