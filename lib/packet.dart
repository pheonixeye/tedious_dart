// ignore_for_file: constant_identifier_names

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tedious_dart/meta/annotations.dart';

const HEADER_LENGTH = 8;

const Map<String, int> PACKETTYPE = {
  "SQL_BATCH": 0x01,
  "RPC_REQUEST": 0x03,
  "TABULAR_RESULT": 0x04,
  "ATTENTION": 0x06,
  "BULK_LOAD": 0x07,
  "TRANSACTION_MANAGER": 0x0E,
  "LOGIN7": 0x10,
  "NTLMAUTH_PKT": 0x11,
  "PRELOGIN": 0x12,
  "FEDAUTH_TOKEN": 0x08
};

final Map<int, String> packetTypeByValue =
    PACKETTYPE.map((key, value) => MapEntry(value, key));

const Map<String, int> STATUS = {
  "NORMAL": 0x00,
  "EOM": 0x01,
  "IGNORE": 0x02,
  "RESETCONNECTION": 0x08,
  "RESETCONNECTIONSKIPTRAN": 0x10
};

enum OFFSET {
  Type(0),
  Status(1),
  Length(2),
  SPID(4),
  PacketID(6),
  Window(7);

  final int value;
  const OFFSET(this.value);
}

const DEFAULT_SPID = 0;

const DEFAULT_PACKETID = 1;

const DEFAULT_WINDOW = 0;

const NL = '\n';

class Packet {
  late Buffer buffer;

  @DynamicParameterType('bufferOrType', 'Buffer | int')
  Packet(dynamic bufferOrType) {
    if (bufferOrType is Buffer) {
      buffer = bufferOrType;
    } else {
      final type = bufferOrType as int;
      buffer = Buffer.alloc(HEADER_LENGTH, 0);
      buffer.writeUInt8(type, OFFSET.Type.value);
      buffer.writeUInt8(STATUS['NORMAL']!, OFFSET.Status.value);
      buffer.writeUInt16BE(DEFAULT_SPID, OFFSET.SPID.value);
      buffer.writeUInt8(DEFAULT_PACKETID, OFFSET.PacketID.value);
      buffer.writeUInt8(DEFAULT_WINDOW, OFFSET.Window.value);
      setLength();
    }
  }

  void setLength() {
    buffer.writeUInt16BE(buffer.length, OFFSET.Length.value);
  }

  int length() {
    return buffer.readUInt16BE(OFFSET.Length.value);
  }

  void resetConnection(bool reset) {
    var status = buffer.readUInt8(OFFSET.Status.value).toInt();
    if (reset) {
      status |= STATUS['RESETCONNECTION']!;
    } else {
      status &= 0xFF - STATUS['RESETCONNECTION']!;
    }
    buffer.writeUInt8(status, OFFSET.Status.value);
  }

  bool? last(bool? last) {
    var status = buffer.readUInt8(OFFSET.Status.value);
    if (last != null) {
      if (last) {
        status |= STATUS['EOM']!;
      } else {
        status &= 0xFF - STATUS['EOM']!;
      }
      buffer.writeUInt8(status, OFFSET.Status.value);
    }
    return isLast();
  }

  void ignore(bool last) {
    var status = buffer.readUInt8(OFFSET.Status.value);
    if (last) {
      status |= STATUS['IGNORE']!;
    } else {
      status &= 0xFF - STATUS['IGNORE']!;
    }
    buffer.writeUInt8(status, OFFSET.Status.value);
  }

  bool isLast() {
    return buffer.readUInt8(OFFSET.Status.value) == STATUS['EOM']!;
  }

  int? packetId([int? packetId]) {
    if (packetId != null) {
      buffer.writeUInt8(packetId % 256, OFFSET.PacketID.value);
    }
    return buffer.readUInt8(OFFSET.PacketID.value);
  }

  Packet addData(Buffer data) {
    buffer = Buffer.concat([buffer, data]);
    setLength();
    return this;
  }

  Buffer data() {
    return buffer.slice(HEADER_LENGTH);
  }

  int type() {
    return buffer.readUInt8(OFFSET.Type.value);
  }

  String statusAsString() {
    final int status = buffer.readUInt8(OFFSET.Status.value);
    List statuses = [];

    for (String name in STATUS.keys) {
      final value = STATUS[name];

      if (value == status) {
        statuses.add(name);
      }
    }

    return statuses.join(' ').trim();
  }

  String headerToString({String indent = ''}) {
    final text = sprintf(
        'type:0x%02X(%s), status:0x%02X(%s), length:0x%04X, spid:0x%04X, packetId:0x%02X, window:0x%02X',
        [
          buffer.readUInt8(OFFSET.Type.value),
          packetTypeByValue[buffer.readUInt8(OFFSET.Type.value)],
          buffer.readUInt8(OFFSET.Status.value),
          statusAsString(),
          buffer.readUInt16BE(OFFSET.Length.value),
          buffer.readUInt16BE(OFFSET.SPID.value),
          buffer.readUInt8(OFFSET.PacketID.value),
          buffer.readUInt8(OFFSET.Window.value),
        ]);
    return indent + text;
  }

  String dataToString({String indent = ''}) {
    const BYTES_PER_GROUP = 0x04;
    const CHARS_PER_GROUP = 0x08;
    const BYTES_PER_LINE = 0x20;
    final data = this.data();

    var dataDump = '';
    var chars = '';

    for (var offset = 0; offset < data.length; offset++) {
      if (offset % BYTES_PER_LINE == 0) {
        dataDump += indent;
        dataDump += sprintf('%04X  ', [offset]);
      }

      if (data[offset] < 0x20 || data[offset] > 0x7E) {
        chars += '.';
        if (((offset + 1) % CHARS_PER_GROUP == 0) &&
            !((offset + 1) % BYTES_PER_LINE == 0)) {
          chars += ' ';
        }
      } else {
        chars += String.fromCharCode(data[offset]);
      }

      if (data[offset] != null) {
        dataDump += sprintf('%02X', [data[offset]]);
      }

      if (((offset + 1) % BYTES_PER_GROUP == 0) &&
          !((offset + 1) % BYTES_PER_LINE == 0)) {
        dataDump += ' ';
      }

      if ((offset + 1) % BYTES_PER_LINE == 0) {
        dataDump += '  $chars';
        chars = '';
        if (offset < data.length - 1) {
          dataDump += NL;
        }
      }
    }

    if (chars.isNotEmpty) {
      dataDump += '  $chars';
    }

    return dataDump;
  }

  @override
  String toString({String indent = ''}) {
    return '${headerToString(indent: indent)}\n${dataToString(indent: indent + indent)}';
  }

  String payloadString() {
    return '';
  }
}

bool isPacketComplete(Buffer potentialPacketBuffer) {
  if (potentialPacketBuffer.length < HEADER_LENGTH) {
    return false;
  } else {
    return potentialPacketBuffer.length >=
        potentialPacketBuffer.readUInt16BE(OFFSET.Length.value);
  }
}

int packetLength(Buffer potentialPacketBuffer) {
  return potentialPacketBuffer.readUInt16BE(OFFSET.Length.value);
}
