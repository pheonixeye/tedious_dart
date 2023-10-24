// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_this

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
      this.buffer = bufferOrType;
    } else {
      final type = bufferOrType as int;
      this.buffer = Buffer.alloc(HEADER_LENGTH, 0);
      this.buffer.writeUInt8(type, OFFSET.Type.value);
      this.buffer.writeUInt8(STATUS['NORMAL']!, OFFSET.Status.value);
      //todo: change eom according to message / packet size
      this.buffer.writeUInt16BE(DEFAULT_SPID, OFFSET.SPID.value);
      this.buffer.writeUInt8(DEFAULT_PACKETID, OFFSET.PacketID.value);
      this.buffer.writeUInt8(DEFAULT_WINDOW, OFFSET.Window.value);
      this.setLength();
      print('packet header ==>>');
      print(buffer.buffer);
    }
  }

  void setLength() {
    this.buffer.writeUInt16BE(this.buffer.length, OFFSET.Length.value);
  }

  int length() {
    return this.buffer.readUInt16BE(OFFSET.Length.value);
  }

  void resetConnection(bool reset) {
    var status = this.buffer.readUInt8(OFFSET.Status.value).toInt();
    if (reset) {
      status |= STATUS['RESETCONNECTION']!;
    } else {
      status &= 0xFF - STATUS['RESETCONNECTION']!;
    }
    this.buffer.writeUInt8(status, OFFSET.Status.value);
  }

  bool? last(bool? last) {
    var status = this.buffer.readUInt8(OFFSET.Status.value);
    if (last != null) {
      if (last) {
        status |= STATUS['EOM']!;
      } else {
        status &= 0xFF - STATUS['EOM']!;
      }
      this.buffer.writeUInt8(status, OFFSET.Status.value);
    }
    return this.isLast();
  }

  void ignore(bool last) {
    var status = this.buffer.readUInt8(OFFSET.Status.value);
    if (last) {
      status |= STATUS['IGNORE']!;
    } else {
      status &= 0xFF - STATUS['IGNORE']!;
    }
    this.buffer.writeUInt8(status, OFFSET.Status.value);
  }

  bool isLast() {
    return this.buffer.readUInt8(OFFSET.Status.value) == STATUS['EOM']!;
  }

  int? packetId([int? packetId]) {
    if (packetId != null) {
      this.buffer.writeUInt8(packetId % 256, OFFSET.PacketID.value);
    }
    return this.buffer.readUInt8(OFFSET.PacketID.value);
  }

  Packet addData(Buffer data) {
    this.buffer = Buffer.concat([this.buffer, data]);
    print('packet data after concat ==>>');
    print(buffer.buffer);
    this.setLength();
    return this;
  }

  Buffer data() {
    return this.buffer.slice(HEADER_LENGTH);
  }

  int type() {
    return this.buffer.readUInt8(OFFSET.Type.value);
  }

  String statusAsString() {
    final int status = this.buffer.readUInt8(OFFSET.Status.value);
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
          this.buffer.readUInt8(OFFSET.Type.value),
          packetTypeByValue[this.buffer.readUInt8(OFFSET.Type.value)],
          this.buffer.readUInt8(OFFSET.Status.value),
          this.statusAsString(),
          this.buffer.readUInt16BE(OFFSET.Length.value),
          this.buffer.readUInt16BE(OFFSET.SPID.value),
          this.buffer.readUInt8(OFFSET.PacketID.value),
          this.buffer.readUInt8(OFFSET.Window.value),
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
    return '${this.headerToString(indent: indent)}\n${this.dataToString(indent: indent + indent)}';
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
