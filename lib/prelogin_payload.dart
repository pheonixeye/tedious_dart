// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:magic_buffer/magic_buffer.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';

const optionBufferSize = 20;

class TOKEN {
  static const VERSION = 0x00;
  static const ENCRYPTION = 0x01;
  static const INSTOPT = 0x02;
  static const THREADID = 0x03;
  static const MARS = 0x04;
  static const FEDAUTHREQUIRED = 0x06;
  static const TERMINATOR = 0xFF;
}

const Map<String, int> ENCRYPT = {
  'OFF': 0x00,
  'ON': 0x01,
  'NOT_SUP': 0x02,
  'REQ': 0x03
};

final Map<int, String> encryptByValue = ENCRYPT.map(
  (key, value) {
    return MapEntry(value, key);
  },
);

const Map<String, int> MARS = {
  'OFF': 0x00,
  'ON': 0x01,
};

final Map<int, String> marsByValue =
    MARS.map((key, value) => MapEntry(value, key));

class PreloginPayloadVersion {
  final num major;
  final num minor;
  final num build;
  final num subbuild;

  PreloginPayloadVersion({
    required this.major,
    required this.minor,
    required this.build,
    required this.subbuild,
  });
}

class PreloginPayloadOptions {
  bool? encrypt;
  PreloginPayloadVersion? version;

  PreloginPayloadOptions({
    this.encrypt,
    this.version,
  });
}

class PreloginPayload {
  Buffer? data;
  PreloginPayloadOptions? options;

  PreloginPayloadVersion? version;

  num? encryption;
  String? encryptionString;

  num? instance;

  num? threadId;

  num? mars;
  String? marsString;
  num? fedAuthRequired;

  PreloginPayload({
    this.data,
    this.encryption,
    this.encryptionString,
    this.fedAuthRequired,
    this.instance,
    this.mars,
    this.marsString,
    this.options,
    this.threadId,
    this.version,
  }) {
    if (data == null) {
      options = PreloginPayloadOptions(
        encrypt: false,
        version:
            PreloginPayloadVersion(major: 0, minor: 0, build: 0, subbuild: 0),
      );
    } else {
      createOptions();
    }
    extractOptions();
  }

  createOptions() {
    var options = [
      createVersionOption(),
      createEncryptionOption(),
      createInstanceOption(),
      createThreadIdOption(),
      createMarsOption(),
      createFedAuthOption(),
    ];

    var length = 0;
    for (var i = 0, len = options.length; i < len; i++) {
      var option = options[i];
      length += 5 + option.data.length as int;
    }
    length++; // terminator
    data = Buffer.alloc(length, 0);
    var optionOffset = 0;
    var optionDataOffset = 5 * options.length + 1;

    for (var j = 0, len = options.length; j < len; j++) {
      var option = options[j];
      data!.writeUInt8(option.token, optionOffset + 0);
      data!.writeUInt16BE(optionDataOffset, optionOffset + 1);
      data!.writeUInt16BE(option.data.length, optionOffset + 3);
      optionOffset += 5;
      option.data.copy(data, optionDataOffset);
      optionDataOffset += option.data.length as int;
    }

    data!.writeUInt8(TOKEN.TERMINATOR, optionOffset);
  }

  createVersionOption() {
    var buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(options!.version!.major.toInt());
    buffer.writeUInt8(options!.version!.minor.toInt());
    buffer.writeUInt16BE(options!.version!.build.toInt());
    buffer.writeUInt16BE(options!.version!.subbuild.toInt());
    return {
      'token': TOKEN.VERSION,
      'data': buffer.data,
    };
  }

  createEncryptionOption() {
    var buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    if (options!.encrypt != null) {
      buffer.writeUInt8(ENCRYPT['ON']!);
    } else {
      buffer.writeUInt8(ENCRYPT['NOT_SUP']!);
    }
    return {
      'token': TOKEN.ENCRYPTION,
      'data': buffer.data,
    };
  }

  createInstanceOption() {
    var buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(0x00);
    return {
      'token': TOKEN.INSTOPT,
      'data': buffer.data,
    };
  }

  createThreadIdOption() {
    var buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt32BE(0x00);
    return {
      'token': TOKEN.THREADID,
      'data': buffer.data,
    };
  }

  createMarsOption() {
    var buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(MARS['OFF']!);
    return {
      'token': TOKEN.MARS,
      'data': buffer.data,
    };
  }

  createFedAuthOption() {
    var buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(0x01);
    return {
      'token': TOKEN.FEDAUTHREQUIRED,
      'data': buffer.data,
    };
  }

  extractOptions() {
    var offset = 0;
    while (data![offset] != TOKEN.TERMINATOR) {
      var dataOffset =
          data!.readUInt16BE(offset + 1) as int; //type casting num to int
      var dataLength =
          data!.readUInt16BE(offset + 3) as int; //type casting num to int
      switch (data![offset]) {
        case TOKEN.VERSION:
          extractVersion(dataOffset);
          break;
        case TOKEN.ENCRYPTION:
          extractEncryption(dataOffset);
          break;
        case TOKEN.INSTOPT:
          extractInstance(dataOffset);
          break;
        case TOKEN.THREADID:
          if (dataLength > 0) {
            extractThreadId(dataOffset);
          }
          break;
        case TOKEN.MARS:
          extractMars(dataOffset);
          break;
        case TOKEN.FEDAUTHREQUIRED:
          extractFedAuth(dataOffset);
          break;
      }
      offset += 5;
      dataOffset += dataLength;
    }
  }

  extractVersion(int offset) {
    version = PreloginPayloadVersion(
        major: data!.readUInt8(offset + 0),
        minor: data!.readUInt8(offset + 1),
        build: data!.readUInt16BE(offset + 2),
        subbuild: data!.readUInt16BE(offset + 4));
  }

  extractEncryption(int offset) {
    encryption = data!.readUInt8(offset);
    encryptionString = encryptByValue[encryption];
  }

  extractInstance(int offset) {
    instance = data!.readUInt8(offset);
  }

  extractThreadId(int offset) {
    threadId = data!.readUInt32BE(offset);
  }

  extractMars(int offset) {
    mars = data!.readUInt8(offset);
    marsString = marsByValue[mars];
  }

  extractFedAuth(int offset) {
    fedAuthRequired = data!.readUInt8(offset);
  }

  @override
  toString({String indent = ''}) {
    return '${indent}PreLogin - ${sprintf('version:%d.%d.%d.%d, encryption:0x%02X(%s), instopt:0x%02X, threadId:0x%08X, mars:0x%02X(%s)', [
          version!.major,
          version!.minor,
          version!.build,
          version!.subbuild,
          encryption ?? 0,
          encryptionString ?? '',
          instance ?? 0,
          threadId ?? 0,
          mars ?? 0,
          marsString ?? '',
        ])}';
  }
}
