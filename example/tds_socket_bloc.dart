import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/TDS_Socket/ev.dart';
import 'package:tedious_dart/TDS_Socket/tds_socket.dart';
import 'package:tedious_dart/conn_authentication.dart';
import 'package:tedious_dart/conn_const_typedef.dart';
import 'package:tedious_dart/library.dart';
import 'package:tedious_dart/login7_payload.dart';
import 'package:tedious_dart/packet.dart';
import 'package:tedious_dart/prelogin_payload.dart';
import 'package:tedious_dart/tds_versions.dart';

final preloginPayload = PreloginPayload(
  PreloginPayloadOptions(),
);

void main(List<String> args) async {
  final socket = TdsSocket();

  socket.add(ConnectEvent());

  final Packet preLoginPacket = Packet(PACKETTYPE['PRELOGIN']!);

  preLoginPacket.addData(preloginPayload.data);

  print(preLoginPacket.toString());

  socket.add(WriteEvent(preLoginPacket.buffer.buffer));

  socket.add(ReadEvent());

  // final login7packet = Packet(PACKETTYPE["LOGIN7"]!);

  // final authType = AuthenticationType(
  //   type: AuthType.default_,
  //   options: AuthOptions(
  //     userName: 'kz',
  //     password: 'admin',
  //   ),
  // );

  // final login7Options = Login7Options(
  //   tdsVersion: TDSVERSIONS[DEFAULT_TDS_VERSION]!,
  //   packetSize: DEFAULT_PACKET_SIZE,
  //   clientProgVer: 0,
  //   connectionId: 0,
  //   clientLcid: 0x00000409,
  // );

  // final login7Payload = Login7Payload(
  //   login7Options: login7Options,
  //   userName: authType.auth.options?.userName,
  //   password: authType.auth.options?.password,
  //   appName: LIBRARYNAME,
  //   libraryName: LIBRARYNAME,
  //   language: DEFAULT_LANGUAGE,
  //   database: "test",
  //   hostname: '127.0.0.1',
  //   serverName: 'kareemzaher',
  //   clientId: Buffer.from([1, 2, 3, 4, 5, 6]),
  // );

  // login7packet.addData(login7Payload.toBuffer());

  // socket.add(WriteEvent(login7packet.buffer.buffer));

  // socket.add(ReadEvent());
}
