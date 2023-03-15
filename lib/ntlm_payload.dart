import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:pointycastle/digests/md4.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';

class NTLMPacket {
  Buffer target;
  Buffer nonce;

  NTLMPacket({
    required this.target,
    required this.nonce,
  });
}

class NTLMOptions {
  String? domain;
  String? userName;
  String? password;
  NTLMPacket? ntlmpacket;

  NTLMOptions({
    this.domain,
    this.ntlmpacket,
    this.password,
    this.userName,
  });
}

class NTLMResponsePayload {
  Buffer? data;
  NTLMOptions loginData;

  NTLMResponsePayload({
    required this.data,
    required this.loginData,
  }) {
    data = createResponse(loginData);
  }

  @override
  toString({String indent = ''}) {
    return '${indent}NTLM Auth';
  }

  Buffer createResponse(NTLMOptions challenge) {
    final clientNonce = createClientNonce();
    final lmv2len = 24;
    final ntlmv2len = 16;
    final domain = challenge.domain;
    final username = challenge.userName;
    final password = challenge.password;
    final ntlmData = challenge.ntlmpacket;
    final serverData = ntlmData!.target;
    final serverNonce = ntlmData.nonce;
    final bufferLength = 64 +
        (domain!.length * 2) +
        (username!.length * 2) +
        lmv2len +
        ntlmv2len +
        8 +
        8 +
        8 +
        4 +
        serverData.length +
        4;
    final data = WritableTrackingBuffer(initialSize: bufferLength);
    data.position = 0;
    data.writeString('NTLMSSP\u0000', 'utf8');
    data.writeUInt32LE(0x03);
    final baseIdx = 64;
    final dnIdx = baseIdx;
    final unIdx = dnIdx + domain.length * 2;
    final l2Idx = unIdx + username.length * 2;
    final ntIdx = l2Idx + lmv2len;
    data.writeUInt16LE(lmv2len);
    data.writeUInt16LE(lmv2len);
    data.writeUInt32LE(l2Idx);
    data.writeUInt16LE(ntlmv2len);
    data.writeUInt16LE(ntlmv2len);
    data.writeUInt32LE(ntIdx);
    data.writeUInt16LE(domain.length * 2);
    data.writeUInt16LE(domain.length * 2);
    data.writeUInt32LE(dnIdx);
    data.writeUInt16LE(username.length * 2);
    data.writeUInt16LE(username.length * 2);
    data.writeUInt32LE(unIdx);
    data.writeUInt16LE(0);
    data.writeUInt16LE(0);
    data.writeUInt32LE(baseIdx);
    data.writeUInt16LE(0);
    data.writeUInt16LE(0);
    data.writeUInt32LE(baseIdx);
    data.writeUInt16LE(0x8201);
    data.writeUInt16LE(0x08);
    data.writeString(domain, 'ucs2');
    data.writeString(username, 'ucs2');
    final lmv2Data =
        lmv2Response(domain, username, password!, serverNonce, clientNonce);
    data.copyFrom(lmv2Data);
    final genTime = DateTime.now().millisecondsSinceEpoch;
    final ntlmDataBuffer = ntlmv2Response(domain, username, password,
        serverNonce, serverData, clientNonce, genTime);
    data.copyFrom(ntlmDataBuffer);
    data.writeUInt32LE(0x0101);
    data.writeUInt32LE(0x0000);
    final timestamp = createTimestamp(genTime);
    data.copyFrom(timestamp);
    data.copyFrom(clientNonce);
    data.writeUInt32LE(0x0000);
    data.copyFrom(serverData);
    data.writeUInt32LE(0x0000);
    return data.data!;
  }

  createClientNonce() {
    final clientNonce = Buffer.alloc(8, 0);
    var nidx = 0;
    while (nidx < 8) {
      clientNonce.writeUInt8((Random().nextInt(255)).ceil(), nidx);
      nidx++;
    }
    return clientNonce;
  }

  ntlmv2Response(
    String domain,
    String user,
    String password,
    Buffer serverNonce,
    Buffer targetInfo,
    Buffer clientNonce,
    num mytime,
  ) {
    final timestamp = createTimestamp(mytime);
    final hash = ntv2Hash(domain, user, password);
    final dataLength = 40 + targetInfo.length;
    final data = Buffer.alloc(dataLength, 0);
    serverNonce.copy(data, 0, 0, 8);
    data.writeUInt32LE(0x101, 8);
    data.writeUInt32LE(0x0, 12);
    timestamp.copy(data, 16, 0, 8);
    clientNonce.copy(data, 24, 0, 8);
    data.writeUInt32LE(0x0, 32);
    targetInfo.copy(data, 36, 0, targetInfo.length);
    data.writeUInt32LE(0x0, 36 + targetInfo.length);
    return hmacMD5(data, hash);
  }

  createTimestamp(num time) {
    final tenthsOfAMicrosecond =
        (BigInt.from(time) + BigInt.from(11644473600)) * BigInt.from(10000000);

    final lo = (tenthsOfAMicrosecond & BigInt.from(0xffffffff));
    final hi = ((tenthsOfAMicrosecond >> BigInt.from(32).toInt()) &
        BigInt.from(0xffffffff));

    final result = Buffer.alloc(8);
    result.writeUInt32LE(lo.toInt(), 0);
    result.writeUInt32LE(hi.toInt(), 4);
    return result;
  }

  lmv2Response(
    String domain,
    String user,
    String password,
    Buffer serverNonce,
    Buffer clientNonce,
  ) {
    final hash = ntv2Hash(domain, user, password);
    final data = Buffer.alloc(serverNonce.length + clientNonce.length, 0);

    serverNonce.copy(data);
    clientNonce.copy(data, serverNonce.length, 0, clientNonce.length);

    final newhash = hmacMD5(data, hash);
    final response = Buffer.alloc(newhash.length + clientNonce.length, 0);

    newhash.copy(response);
    clientNonce.copy(response, newhash.length, 0, clientNonce.length);

    return response;
  }

  ntv2Hash(String domain, String user, String password) {
    final hash = ntHash(password);
    final identity =
        Buffer.from(user.toUpperCase() + domain.toUpperCase(), 0, 0, 'ucs2');
    return hmacMD5(identity, hash);
  }

  ntHash(String text) {
    final unicodeString = Buffer.from(text, 0, 0, 'ucs2');
    var m = MD4Digest().process(unicodeString.buffer);
    return Buffer.from(m);
    //TODO: REVISE
  }

  hmacMD5(Buffer data, Buffer key) {
    var hmac = Hmac(md5, key.buffer);
    var output = AccumulatorSink<Digest>();
    ByteConversionSink input = hmac.startChunkedConversion(output);
    input.add(data.buffer);
    input.close();
    return output.events.first;
    //TODO: REVISE
  }
}
