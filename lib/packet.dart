// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_this

import 'package:node_interop/buffer.dart';
import 'package:node_interop/js.dart';
import 'package:sprintf/sprintf.dart';

const HEADER_LENGTH = 8;

const Map<String, int> TYPE = {
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

final Map<int, String> typeByValue =
    TYPE.map((key, value) => MapEntry(value, key));

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
  dynamic buffer;

  Packet(this.buffer) {
    if (buffer.runtimeType == Buffer) {
      this.buffer = buffer;
    } else {
      this.buffer = Buffer.alloc(HEADER_LENGTH, 0);
      this.buffer!.writeUInt8(buffer as int, OFFSET.Type.value);
      this.buffer!.writeUInt8(STATUS['NORMAL']!, OFFSET.Status.value);
      this.buffer!.writeUInt16BE(DEFAULT_SPID, OFFSET.SPID.value);
      this.buffer!.writeUInt8(DEFAULT_PACKETID, OFFSET.PacketID.value);
      this.buffer!.writeUInt8(DEFAULT_WINDOW, OFFSET.Window.value);
      this.setLength();
    }
  }

  setLength() {
    this.buffer!.writeUInt16BE(this.buffer!.length, OFFSET.Length.value);
  }

  length() {
    return this.buffer!.readUInt16BE(OFFSET.Length.value);
  }

  resetConnection(bool reset) {
    var status = this.buffer!.readUInt8(OFFSET.Status.value).toInt();
    if (reset) {
      status |= STATUS['RESETCONNECTION']!;
    } else {
      status &= 0xFF - STATUS['RESETCONNECTION']!;
    }
    this.buffer!.writeUInt8(status, OFFSET.Status.value);
  }

  last(bool? last) {
    var status = this.buffer!.readUInt8(OFFSET.Status.value).toInt();
    if (last != null) {
      if (last) {
        status |= STATUS['EOM']!;
      } else {
        status &= 0xFF - STATUS['EOM']!;
      }
      this.buffer!.writeUInt8(status, OFFSET.Status.value);
    }
    return this.isLast();
  }

  ignore(bool last) {
    var status = this.buffer!.readUInt8(OFFSET.Status.value).toInt();
    if (last) {
      status |= STATUS['IGNORE']!;
    } else {
      status &= 0xFF - STATUS['IGNORE']!;
    }
    this.buffer!.writeUInt8(status, OFFSET.Status.value);
  }

  //identify return type ==>> bool
  bool isLast() {
    return (this.buffer!.readUInt8(OFFSET.Status.value).toInt() &
            // ignore: unnecessary_null_comparison
            STATUS['EOM']!) !=
        null;
  }

  packetId(int? packetId) {
    if (packetId != null) {
      this.buffer!.writeUInt8(packetId % 256, OFFSET.PacketID.value);
    }
    return this.buffer!.readUInt8(OFFSET.PacketID.value);
  }

  addData(Buffer data) {
    this.buffer = Buffer.concat([this.buffer, data]);
    this.setLength();
    return this;
  }

  data() {
    return this.buffer!.slice(HEADER_LENGTH);
  }

  type() {
    return this.buffer!.readUInt8(OFFSET.Type.value);
  }

  statusAsString() {
    final status = this.buffer?.readUInt8(OFFSET.Status.value);
    List statuses = [];

    for (var name in STATUS.entries) {
      final value = STATUS[name];

      //TODO: implement better algorithm
      if (value != null && status != null) {
        statuses.add(name);
      } else {
        statuses.add(null);
      }
    }

    return statuses.join(' ').trim();
  }

  headerToString({String indent = ''}) {
    final text = sprintf(
        'type:0x%02X(%s), status:0x%02X(%s), length:0x%04X, spid:0x%04X, packetId:0x%02X, window:0x%02X',
        [
          this.buffer!.readUInt8(OFFSET.Type.value),
          typeByValue[this.buffer!.readUInt8(OFFSET.Type.value)],
          this.buffer!.readUInt8(OFFSET.Status.value),
          this.statusAsString(),
          this.buffer!.readUInt16BE(OFFSET.Length.value),
          this.buffer!.readUInt16BE(OFFSET.SPID.value),
          this.buffer!.readUInt8(OFFSET.PacketID.value),
          this.buffer!.readUInt8(OFFSET.Window.value),
        ]);
    return indent + text;
  }

  dataToString({String indent = ''}) {
    const BYTES_PER_GROUP = 0x04;
    const CHARS_PER_GROUP = 0x08;
    const BYTES_PER_LINE = 0x20;
    final data = this.data();

    var dataDump = '';
    var chars = '';

    for (var offset = 0; offset < data.length; offset++) {
      if (offset % BYTES_PER_LINE == 0) {
        dataDump += indent;
        dataDump += sprintf('%04X  ', offset);
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
        dataDump += sprintf('%02X', data[offset]);
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
  toString({String indent = ''}) {
    return this.headerToString(indent: indent) +
        '\n' +
        this.dataToString(indent: indent + indent);
  }

  payloadString() {
    return '';
  }
}

isPacketComplete(Buffer potentialPacketBuffer) {
  if (potentialPacketBuffer.length < HEADER_LENGTH) {
    return false;
  } else {
    return potentialPacketBuffer.length >=
        potentialPacketBuffer.readUInt16BE(OFFSET.Length.value);
  }
}

packetLength(Buffer potentialPacketBuffer) {
  return potentialPacketBuffer.readUInt16BE(OFFSET.Length.value);
}
