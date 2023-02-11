// ignore_for_file: unused_element

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

class _Data {
  String? magic;
  num? type;
  num? domainLen;
  num? domainMax;
  num? domainOffset;
  num? flags;
  Buffer? nonce;
  Buffer? zeroes;
  num? targetLen;
  num? targetMax;
  num? targetOffset;
  Buffer? oddData;
  String? domain;
  Buffer? target;

  _Data({
    this.domain,
    this.domainLen,
    this.domainMax,
    this.domainOffset,
    this.flags,
    this.magic,
    this.nonce,
    this.oddData,
    this.target,
    this.targetLen,
    this.targetMax,
    this.targetOffset,
    this.type,
    this.zeroes,
  });
}

parseChallenge(Buffer buffer) {
  _Data challenge = _Data();

  challenge.magic = buffer.slice(0, 8).toString('utf8');
  challenge.type = buffer.readInt32LE(8);
  challenge.domainLen = buffer.readInt16LE(12);
  challenge.domainMax = buffer.readInt16LE(14);
  challenge.domainOffset = buffer.readInt32LE(16);
  challenge.flags = buffer.readInt32LE(20);
  challenge.nonce = buffer.slice(24, 32);
  challenge.zeroes = buffer.slice(32, 40);
  challenge.targetLen = buffer.readInt16LE(40);
  challenge.targetMax = buffer.readInt16LE(42);
  challenge.targetOffset = buffer.readInt32LE(44);
  challenge.oddData = buffer.slice(48, 56);
  challenge.domain =
      buffer.slice(56, 56 + challenge.domainLen! as int).toString('ucs2');
  challenge.target = buffer.slice(56 + challenge.domainLen! as int,
      (56 + challenge.domainLen! + challenge.targetLen!) as int);

  return challenge;
}

sspiParser(
  StreamParser parser,
  ParserOptions options,
  void Function(SSPIToken token) callback,
) {
  parser.readUsVarByte((buffer) {
    callback(SSPIToken(
      ntlmpacket: parseChallenge(buffer),
      ntlmpacketBuffer: buffer,
    ));
  });
}
