// ignore_for_file: unused_element

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token.dart';

class ChallengeData {
  String? magic;
  int? type;
  int? domainLen;
  int? domainMax;
  int? domainOffset;
  int? flags;
  Buffer? nonce;
  Buffer? zeroes;
  int? targetLen;
  int? targetMax;
  int? targetOffset;
  Buffer? oddData;
  String? domain;
  Buffer? target;

  ChallengeData({
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

ChallengeData parseChallenge(Buffer buffer) {
  ChallengeData challenge = ChallengeData();

  challenge.magic = buffer.slice(0, 8).toString_({'encoding': 'utf8'});
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
  challenge.domain = buffer
      .slice(56, 56 + challenge.domainLen!)
      .toString_({'encoding': 'ucs2'});
  challenge.target = buffer.slice(56 + challenge.domainLen!,
      (56 + challenge.domainLen! + challenge.targetLen!));

  return challenge;
}

void sspiParser(
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
