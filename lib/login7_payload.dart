// ignore_for_file: constant_identifier_names

import 'package:node_interop/node_interop.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tedious_dart/extensions/subscript_on_iterable.dart';
// ignore: unused_import
import 'package:tedious_dart/extensions/bracket_on_buffer.dart';
import 'package:tedious_dart/tds_versions.dart';

const Map<String, int> FLAGS_1 = {
  'ENDIAN_LITTLE': 0x00,
  'ENDIAN_BIG': 0x01,
  'CHARSET_ASCII': 0x00,
  'CHARSET_EBCDIC': 0x02,
  'FLOAT_IEEE_754': 0x00,
  'FLOAT_VAX': 0x04,
  'FLOAT_ND5000': 0x08,
  'BCP_DUMPLOAD_ON': 0x00,
  'BCP_DUMPLOAD_OFF': 0x10,
  'USE_DB_ON': 0x00,
  'USE_DB_OFF': 0x20,
  'INIT_DB_WARN': 0x00,
  'INIT_DB_FATAL': 0x40,
  'SET_LANG_WARN_OFF': 0x00,
  'SET_LANG_WARN_ON': 0x80
};

const Map<String, int> FLAGS_2 = {
  'INIT_LANG_WARN': 0x00,
  'INIT_LANG_FATAL': 0x01,
  'ODBC_OFF': 0x00,
  'ODBC_ON': 0x02,
  'F_TRAN_BOUNDARY': 0x04,
  'F_CACHE_CONNECT': 0x08,
  'USER_NORMAL': 0x00,
  'USER_SERVER': 0x10,
  'USER_REMUSER': 0x20,
  'USER_SQLREPL': 0x40,
  'INTEGRATED_SECURITY_OFF': 0x00,
  'INTEGRATED_SECURITY_ON': 0x80
};

const Map<String, int> TYPE_FLAGS = {
  'SQL_DFLT': 0x00,
  'SQL_TSQL': 0x08,
  'OLEDB_OFF': 0x00,
  'OLEDB_ON': 0x10,
  'READ_WRITE_INTENT': 0x00,
  'READ_ONLY_INTENT': 0x20
};

const Map<String, int> FLAGS_3 = {
  'CHANGE_PASSWORD_NO': 0x00,
  'CHANGE_PASSWORD_YES': 0x01,
  'BINARY_XML': 0x02,
  'SPAWN_USER_INSTANCE': 0x04,
  'UNKNOWN_COLLATION_HANDLING': 0x08,
  'EXTENSION_USED': 0x10
};

const Map<String, int> FEDAUTH_OPTIONS = {
  'FEATURE_ID': 0x02,
  'LIBRARY_SECURITYTOKEN': 0x01,
  'LIBRARY_ADAL': 0x02,
  'FEDAUTH_YES_ECHO': 0x01,
  'FEDAUTH_NO_ECHO': 0x00,
  'ADAL_WORKFLOW_USER_PASS': 0x01,
  'ADAL_WORKFLOW_INTEGRATED': 0x02
};

const FEATURE_EXT_TERMINATOR = 0xFF;

class Login7Options {
  num? tdsVersion;
  num? packetSize;
  num? clientProgVer;
  num? clientPid;
  num? connectionId;
  num? clientTimeZone;
  num? clientLcid;

  Login7Options({
    clientLcid,
    clientPid,
    clientProgVer,
    clientTimeZone,
    connectionId,
    packetSize,
    tdsVersion,
  });
}

abstract class _FedAuth {
  String type;
  bool echo;
  String? workflow;
  String? fedAuthToken;

  _FedAuth({
    required this.type,
    required this.echo,
    this.fedAuthToken,
    this.workflow,
  });
}

class FedAuth extends _FedAuth {
  FedAuth({
    required super.type,
    required super.echo,
    super.fedAuthToken,
    super.workflow,
  });
}

class Login7Payload {
  Login7Options? login7Options;

  bool readOnlyIntent;
  bool initDbFatal;

  String? userName;
  String? password;
  String? serverName;
  String? appName;
  String? hostname;
  String? libraryName;
  String? language;
  String? database;
  Buffer? clientId;
  Buffer? sspi;
  String? attachDbFile;
  String? changePassword;

  FedAuth? fedAuth;

  Login7Payload({
    this.login7Options,
    this.readOnlyIntent = false,
    this.initDbFatal = false,
    this.fedAuth,
    this.userName,
    this.password,
    this.serverName,
    this.appName,
    this.hostname,
    this.libraryName,
    this.language,
    this.database,
    this.clientId,
    this.sspi,
    this.attachDbFile,
    this.changePassword,
  });

  toBuffer() {
    var fixedData = Buffer.alloc(94);
    var buffers = [fixedData];

    var offset = 0;
    var dataOffset = fixedData.length;

    // Length: 4-byte
    offset = fixedData.writeUInt32LE(0, offset);

    // TDSVersion: 4-byte
    offset = fixedData.writeUInt32LE(login7Options!.tdsVersion as int, offset);

    // PacketSize: 4-byte
    offset = fixedData.writeUInt32LE(login7Options!.packetSize as int, offset);

    // ClientProgVer: 4-byte
    offset =
        fixedData.writeUInt32LE(login7Options!.clientProgVer as int, offset);

    // ClientPID: 4-byte
    offset = fixedData.writeUInt32LE(login7Options!.clientPid as int, offset);

    // ConnectionID: 4-byte
    offset =
        fixedData.writeUInt32LE(login7Options!.connectionId as int, offset);

    // OptionFlags1: 1-byte
    offset = fixedData.writeUInt8(buildOptionFlags1(), offset);

    // OptionFlags2: 1-byte
    offset = fixedData.writeUInt8(buildOptionFlags2(), offset);

    // TypeFlags: 1-byte
    offset = fixedData.writeUInt8(buildTypeFlags(), offset);

    // OptionFlags3: 1-byte
    offset = fixedData.writeUInt8(buildOptionFlags3(), offset);

    // ClientTimZone: 4-byte
    offset =
        fixedData.writeInt32LE(login7Options!.clientTimeZone as int, offset);

    // ClientLCID: 4-byte
    offset = fixedData.writeUInt32LE(login7Options!.clientLcid as int, offset);

    // ibHostName: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchHostName: 2-byte
    if (hostname != null) {
      var buffer = Buffer.from(hostname, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(dataOffset, offset);
    }

    // ibUserName: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchUserName: 2-byte
    if (userName != null) {
      var buffer = Buffer.from(userName, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ibPassword: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchPassword: 2-byte
    if (password != null) {
      var buffer = Buffer.from(password, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(scramblePassword(buffer));
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ibAppName: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchAppName: 2-byte
    if (appName != null) {
      var buffer = Buffer.from(appName, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ibServerName: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchServerName: 2-byte
    if (serverName != null) {
      var buffer = Buffer.from(serverName, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // (ibUnused / ibExtension): 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // (cchUnused / cbExtension): 2-byte
    var extensions = buildFeatureExt();
    offset = fixedData.writeUInt16LE(4, offset);
    var extensionOffset = Buffer.alloc(4);
    extensionOffset.writeUInt32LE(dataOffset += 4, 0);
    dataOffset += extensions.length;
    buffers.add(extensionOffset);
    buffers.add(extensions);

    // ibCltIntName: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchCltIntName: 2-byte
    if (libraryName != null) {
      var buffer = Buffer.from(libraryName, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ibLanguage: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchLanguage: 2-byte
    if (language != null) {
      var buffer = Buffer.from(language, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ibDatabase: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchDatabase: 2-byte
    if (database != null) {
      var buffer = Buffer.from(database, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ClientID: 6-byte
    if (clientId != null) {
      clientId!.copy(fixedData, offset, 0, 6);
    }
    offset += 6;

    // ibSSPI: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cbSSPI: 2-byte
    if (sspi != null) {
      if (sspi!.length > 65535) {
        offset = fixedData.writeUInt16LE(65535, offset);
      } else {
        offset = fixedData.writeUInt16LE(sspi!.length, offset);
      }

      buffers.add(sspi!);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ibAtchDBFile: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchAtchDBFile: 2-byte
    if (attachDbFile != null) {
      var buffer = Buffer.from(attachDbFile, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // ibChangePassword: 2-byte
    offset = fixedData.writeUInt16LE(dataOffset, offset);

    // cchChangePassword: 2-byte
    if (changePassword != null) {
      var buffer = Buffer.from(changePassword, 'ucs2');

      offset = fixedData.writeUInt16LE(buffer.length ~/ 2, offset);
      dataOffset += buffer.length;

      buffers.add(buffer);
    } else {
      offset = fixedData.writeUInt16LE(0, offset);
    }

    // cbSSPILong: 4-byte
    if (sspi != null && sspi!.length > 65535) {
      fixedData.writeUInt32LE(sspi!.length, offset);
    } else {
      fixedData.writeUInt32LE(0, offset);
    }

    var data = Buffer.concat(buffers);
    data.writeUInt32LE(data.length, 0);
    return data;
  }

  buildOptionFlags1() {
    var flags1 = FLAGS_1['ENDIAN_LITTLE']! |
        FLAGS_1['CHARSET_ASCII']! |
        FLAGS_1['FLOAT_IEEE_754']! |
        FLAGS_1['BCP_DUMPLOAD_OFF']! |
        FLAGS_1['USE_DB_OFF']! |
        FLAGS_1['SET_LANG_WARN_ON']!;
    if (initDbFatal) {
      flags1 |= FLAGS_1['INIT_DB_FATAL']!;
    } else {
      flags1 |= FLAGS_1['INIT_DB_WARN']!;
    }
    return flags1;
  }

  Buffer buildFeatureExt() {
    List buffers = [];

    final fedAuth = this.fedAuth;
    if (fedAuth != null) {
      switch (fedAuth.type) {
        case 'ADAL':
          var buffer = Buffer.alloc(7);
          buffer.writeUInt8(FEDAUTH_OPTIONS['FEATURE_ID']!, 0);
          buffer.writeUInt32LE(2, 1);
          buffer.writeUInt8(
              (FEDAUTH_OPTIONS['LIBRARY_ADAL']! << 1) |
                  (fedAuth.echo
                      ? FEDAUTH_OPTIONS['FEDAUTH_YES_ECHO']!
                      : FEDAUTH_OPTIONS['FEDAUTH_NO_ECHO']!),
              5);
          buffer.writeUInt8(
              fedAuth.workflow == 'integrated'
                  ? 0x02
                  : FEDAUTH_OPTIONS['ADAL_WORKFLOW_USER_PASS']!,
              6);
          buffers.add(buffer);
          break;

        case 'SECURITYTOKEN':
          var token = Buffer.from(fedAuth.fedAuthToken, 'ucs2');
          var buf = Buffer.alloc(10);

          var offset = 0;
          offset = buf.writeUInt8(FEDAUTH_OPTIONS['FEATURE_ID']!, offset);
          offset = buf.writeUInt32LE(token.length + 4 + 1, offset);
          offset = buf.writeUInt8(
              (FEDAUTH_OPTIONS['LIBRARY_SECURITYTOKEN']! << 1) |
                  (fedAuth.echo
                      ? FEDAUTH_OPTIONS['FEDAUTH_YES_ECHO']!
                      : FEDAUTH_OPTIONS['FEDAUTH_NO_ECHO']!),
              offset);
          buf.writeInt32LE(token.length, offset);

          buffers.add(buf);
          buffers.add(token);

          break;
      }
    }

    if (TDSVERSIONS[login7Options!.tdsVersion]! >= TDSVERSIONS['7_4']!) {
      // Signal UTF-8 support: Value 0x0A, bit 0 must be set to 1. Added in TDS 7.4.
      const UTF8_SUPPORT_FEATURE_ID = 0x0a;
      const UTF8_SUPPORT_CLIENT_SUPPORTS_UTF8 = 0x01;
      var buf = Buffer.alloc(6);
      buf.writeUInt8(UTF8_SUPPORT_FEATURE_ID, 0);
      buf.writeUInt32LE(1, 1);
      buf.writeUInt8(UTF8_SUPPORT_CLIENT_SUPPORTS_UTF8, 5);
      buffers.add(buf);
    }

    buffers.add(Buffer.from([FEATURE_EXT_TERMINATOR]));
    return Buffer.concat(buffers);
  }

  buildOptionFlags2() {
    var flags2 = FLAGS_2['INIT_LANG_WARN']! |
        FLAGS_2['ODBC_OFF']! |
        FLAGS_2['USER_NORMAL']!;
    if (sspi != null) {
      flags2 |= FLAGS_2['INTEGRATED_SECURITY_ON']!;
    } else {
      flags2 |= FLAGS_2['INTEGRATED_SECURITY_OFF']!;
    }
    return flags2;
  }

  buildTypeFlags() {
    var typeFlags = TYPE_FLAGS['SQL_DFLT']! | TYPE_FLAGS['OLEDB_OFF']!;
    if (readOnlyIntent) {
      typeFlags |= TYPE_FLAGS['READ_ONLY_INTENT']!;
    } else {
      typeFlags |= TYPE_FLAGS['READ_WRITE_INTENT']!;
    }
    return typeFlags;
  }

  buildOptionFlags3() {
    return FLAGS_3['CHANGE_PASSWORD_NO']! |
        FLAGS_3['UNKNOWN_COLLATION_HANDLING']! |
        FLAGS_3['EXTENSION_USED']!;
  }

  scramblePassword(Buffer password) {
    for (int b = 0, len = password.length; b < len; b++) {
      int byte = password.values()[b];
      var lowNibble = byte & 0x0f;
      var highNibble = byte >> 4;
      byte = (lowNibble << 4) | highNibble;
      byte = byte ^ 0xa5;
      password[b] = byte;
    }
    return password;
  }

  @override
  toString({String indent = ''}) {
    // ignore: prefer_interpolation_to_compose_strings
    return indent +
        'Login7 - ' +
        sprintf(
            'TDS:0x%08X, PacketSize:0x%08X, ClientProgVer:0x%08X, ClientPID:0x%08X, ConnectionID:0x%08X',
            [
              login7Options?.tdsVersion,
              login7Options?.packetSize,
              login7Options?.clientProgVer,
              login7Options?.clientPid,
              login7Options?.connectionId
            ]) +
        '\n' +
        indent +
        '         ' +
        sprintf(
            'Flags1:0x%02X, Flags2:0x%02X, TypeFlags:0x%02X, Flags3:0x%02X, ClientTimezone:%d, ClientLCID:0x%08X',
            [
              buildOptionFlags1(),
              buildOptionFlags2(),
              buildTypeFlags(),
              buildOptionFlags3(),
              login7Options?.clientTimeZone,
              login7Options?.clientLcid,
            ]) +
        '\n' +
        indent +
        '         ' +
        sprintf(
            "Hostname:'%s', Username:'%s', Password:'%s', AppName:'%s', ServerName:'%s', LibraryName:'%s'",
            [
              hostname,
              userName,
              password,
              appName,
              serverName,
              libraryName,
            ]) +
        '\n' +
        indent +
        '         ' +
        sprintf(
            "Language:'%s', Database:'%s', SSPI:'%s', AttachDbFile:'%s', ChangePassword:'%s'",
            [
              language,
              database,
              sspi,
              attachDbFile,
              changePassword,
            ]);
  }
}
