import 'dart:io';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/conn_authentication.dart';
// import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/conn_const_typedef.dart';
import 'package:tedious_dart/extensions/to_iterable_on_stream.dart';
// import 'package:tedious_dart/functions/get_initial_sql.dart';
import 'package:tedious_dart/library.dart';
import 'package:tedious_dart/login7_payload.dart';
import 'package:tedious_dart/packet.dart';
import 'package:tedious_dart/prelogin_payload.dart';
import 'package:tedious_dart/sqlbatch_payload.dart';
import 'package:tedious_dart/tds_versions.dart';

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
  print(receivedPacket.dataToString());
  await Future.delayed(duration);
  final login7Packet = applyPacketHeader(
    PACKETTYPE['LOGIN7']!,
    login7Payload.toBuffer(),
  );
  print(login7Payload.toString());
  print(login7Packet.toString());
  socket.write(login7Packet.buffer.buffer);
  await Future.delayed(duration);
  final login7Response = socket.read();
  print('login7');
  final login7ResponsePacket = Packet(Buffer(login7Response));
  print(login7ResponsePacket.toString());
  await Future.delayed(duration);
  print('sqlbatchpayload ==>> sent');
  print(sqlBatchPacket.toString());
  socket.write(sqlBatchPacket.buffer.buffer);
  await Future.delayed(duration);

  final sqlResponse = socket.read();
  print('sqlResponse');
  print(Packet(Buffer(sqlResponse)).toString());
}

const duration = Duration(milliseconds: 100);

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

final authType = AuthenticationType(
  type: 'default',
  options: AuthOptions(
    userName: 'kz',
    password: 'admin',
  ),
);
final login7Options = Login7Options(
  tdsVersion: TDSVERSIONS[DEFAULT_TDS_VERSION]!,
  packetSize: DEFAULT_PACKET_SIZE,
  clientProgVer: 0,
  connectionId: 0,
  clientLcid: 0x00000409,
);
final login7Payload = Login7Payload(
  login7Options: login7Options,
  userName: authType.auth.options?.userName,
  password: authType.auth.options?.password,
  appName: LIBRARYNAME,
  libraryName: LIBRARYNAME,
  language: DEFAULT_LANGUAGE,
  hostname: '127.0.0.1',
  serverName: 'kareemzaher',
  clientId: Buffer.from([1, 2, 3, 4, 5, 6]),
);

const sqltext = 'USE test';

final sqlbatchpayload = SqlBatchPayload(
  sqlText: sqltext,
  txnDescriptor: Buffer.from([0, 0, 0, 0, 0, 0, 0, 0]),
  tdsVersion: '7_4',
);

final sqlBatchPacket = applyPacketHeader(
    PACKETTYPE['SQL_BATCH']!,
    Buffer.from(Buffer.concat(sqlbatchpayload.iterate().toIterable().toList()),
        0, 0, 'ucs2'));
