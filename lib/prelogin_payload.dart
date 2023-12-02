// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tedious_dart/meta/annotations.dart';
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
  final int major;
  final int minor;
  final int build;
  final int subbuild;

  const PreloginPayloadVersion({
    this.major = 0,
    this.minor = 0,
    this.build = 0,
    this.subbuild = 0,
  });
}

class PreloginPayloadOptions {
  bool encrypt;
  PreloginPayloadVersion version;

  PreloginPayloadOptions({
    this.encrypt = false,
    this.version = const PreloginPayloadVersion(),
  });
}

class _OptionData {
  final int token;
  final Buffer data;

  const _OptionData(this.token, this.data);
}

class PreloginPayload {
  late Buffer data;
  late PreloginPayloadOptions options;

  late PreloginPayloadVersion version;
  late int encryption;
  late String encryptionString;
  late int instance;
  late int threadId;
  late int mars;
  late String marsString;
  late int fedAuthRequired;

  @DynamicParameterType('bufferOrOptions', 'Buffer | PreloginPayloadOptions')
  PreloginPayload(dynamic bufferOrOptions) {
    if (bufferOrOptions is Buffer) {
      // ignore: unnecessary_cast
      data = bufferOrOptions as Buffer;
      options = PreloginPayloadOptions();
    } else {
      options = bufferOrOptions as PreloginPayloadOptions;
      createOptions();
    }
    extractOptions();
  }

  createOptions() {
    var options = <_OptionData>[
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
      length += 5 + option.data.length;
    }
    length++; // terminator
    data = Buffer.alloc(length, 0);
    var optionOffset = 0;
    var optionDataOffset = 5 * options.length + 1;

    for (var j = 0, len = options.length; j < len; j++) {
      var option = options[j];
      data.writeUInt8(option.token, optionOffset + 0);
      data.writeUInt16BE(optionDataOffset, optionOffset + 1);
      data.writeUInt16BE(option.data.length, optionOffset + 3);
      optionOffset += 5;
      option.data.copy(data, optionDataOffset);
      optionDataOffset += option.data.length;
    }

    data.writeUInt8(TOKEN.TERMINATOR, optionOffset);
  }

  createVersionOption() {
    final buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(options.version.major.toInt());
    buffer.writeUInt8(options.version.minor.toInt());
    buffer.writeUInt16BE(options.version.build.toInt());
    buffer.writeUInt16BE(options.version.subbuild.toInt());
    print(buffer.data.buffer);
    return _OptionData(
      TOKEN.VERSION,
      buffer.data,
    );
  }

  createEncryptionOption() {
    final buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    if (options.encrypt) {
      buffer.writeUInt8(ENCRYPT['ON']!);
    } else {
      buffer.writeUInt8(ENCRYPT['NOT_SUP']!);
    }
    print('encryption ==>>');
    print(buffer.data.buffer);
    return _OptionData(
      TOKEN.ENCRYPTION,
      buffer.data,
    );
  }

  createInstanceOption() {
    final buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(0x00);
    print(buffer.data.buffer);
    return _OptionData(
      TOKEN.INSTOPT,
      buffer.data,
    );
  }

  createThreadIdOption() {
    final buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt32BE(0x00);
    print(buffer.data.buffer);
    return _OptionData(
      TOKEN.THREADID,
      buffer.data,
    );
  }

  createMarsOption() {
    final buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(MARS['OFF']!);
    print(buffer.data.buffer);
    return _OptionData(
      TOKEN.MARS,
      buffer.data,
    );
  }

  createFedAuthOption() {
    final buffer = WritableTrackingBuffer(initialSize: optionBufferSize);
    buffer.writeUInt8(0x01);
    print(buffer.data.buffer);
    return _OptionData(
      TOKEN.FEDAUTHREQUIRED,
      buffer.data,
    );
  }

  extractOptions() {
    int offset = 0;
    while (data[offset] != TOKEN.TERMINATOR) {
      var dataOffset = data.readUInt16BE(offset + 1);
      final dataLength = data.readUInt16BE(offset + 3);

      switch (data[offset]) {
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
      offset = offset + 5;
      dataOffset = dataLength + dataOffset;
    }
  }

  extractVersion(int offset) {
    version = PreloginPayloadVersion(
        major: data.readUInt8(offset + 0),
        minor: data.readUInt8(offset + 1),
        build: data.readUInt16BE(offset + 2),
        subbuild: data.readUInt16BE(offset + 4));
  }

  extractEncryption(int offset) {
    encryption = data.readUInt8(offset);
    encryptionString = encryptByValue[encryption]!;
  }

  extractInstance(int offset) {
    instance = data.readUInt8(offset);
  }

  extractThreadId(int offset) {
    threadId = data.readUInt32BE(offset);
  }

  extractMars(int offset) {
    mars = data.readUInt8(offset);
    marsString = marsByValue[mars]!;
  }

  extractFedAuth(int offset) {
    fedAuthRequired = data.readUInt8(offset);
  }

  @override
  toString({String indent = ''}) {
    return '${indent}PreLogin - ${sprintf('version:%d.%d.%d.%d, encryption:0x%02X(%s), instopt:0x%02X, threadId:0x%08X, mars:0x%02X(%s)', [
          version.major,
          version.minor,
          version.build,
          version.subbuild,
          encryption,
          encryptionString,
          instance,
          threadId,
          mars,
          marsString,
        ])}';
  }
}
