// ignore_for_file: constant_identifier_names, overridden_fields

import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/metadata_parser.dart';
import 'package:tedious_dart/token/colmetadata_token_parser.dart';

const Map<String, int> TYPE = {
  "ALTMETADATA": 0x88,
  "ALTROW": 0xD3,
  "COLMETADATA": 0x81,
  "COLINFO": 0xA5,
  "DONE": 0xFD,
  "DONEPROC": 0xFE,
  "DONEINPROC": 0xFF,
  "ENVCHANGE": 0xE3,
  "ERROR": 0xAA,
  "FEATUREEXTACK": 0xAE,
  "FEDAUTHINFO": 0xEE,
  "INFO": 0xAB,
  "LOGINACK": 0xAD,
  "NBCROW": 0xD2,
  "OFFSET": 0x78,
  "ORDER": 0xA9,
  "RETURNSTATUS": 0x79,
  "RETURNVALUE": 0xAC,
  "ROW": 0xD1,
  "SSPI": 0xED,
  "TABNAME": 0xA4
};

//TODO: better implement after understanding keyof operator of typescript
typedef HandlerName = String;

abstract class Token {
  final String name;
  final HandlerName handlerName;

  Token({required this.name, required this.handlerName});
}

class ColMetadataToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  final List<ColumnMetadata> columns;

  ColMetadataToken({
    this.name = 'COLMETADATA',
    this.handlerName = 'onColMetadata',
    required this.columns,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class DoneToken extends Token {
  @override
  String name;
  @override
  HandlerName handlerName;

  bool more;
  bool sqlError;
  bool attention;
  bool serverError;
  num? rowCount;
  num curCmd;

  DoneToken({
    this.name = 'Done',
    this.handlerName = 'onDone',
    required this.more,
    required this.sqlError,
    required this.attention,
    required this.serverError,
    required this.rowCount,
    required this.curCmd,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

//TODO: delete
class BaseClass extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  BaseClass({
    this.name = 'DONEINPROC',
    this.handlerName = 'onDoneInProc',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class DoneInProcToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  bool more;
  bool sqlError;
  bool attention;
  bool serverError;
  num? rowCount;
  num curCmd;

  DoneInProcToken({
    this.name = 'DONEINPROC',
    this.handlerName = 'onDoneInProc',
    required this.more,
    required this.sqlError,
    required this.attention,
    required this.serverError,
    required this.rowCount,
    required this.curCmd,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class DoneProcToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  bool more;
  bool sqlError;
  bool attention;
  bool serverError;
  num? rowCount;
  num curCmd;

  DoneProcToken({
    this.name = 'DONEPROC',
    this.handlerName = 'onDoneProc',
    required this.more,
    required this.sqlError,
    required this.attention,
    required this.serverError,
    required this.rowCount,
    required this.curCmd,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class DatabaseEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  String newValue;
  String oldValue;

  DatabaseEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onDatabaseChange',
    required this.newValue,
    required this.oldValue,
    this.type = 'DATABASE',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class LanguageEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  String newValue;
  String oldValue;

  LanguageEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onLanguageChange',
    required this.newValue,
    required this.oldValue,
    this.type = 'LANGUAGE',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class CharsetEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  String newValue;
  String oldValue;

  CharsetEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onCharsetChange',
    required this.newValue,
    required this.oldValue,
    this.type = 'CHARSET',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class PacketSizeEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  String newValue;
  String oldValue;

  PacketSizeEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onPacketSizeChange',
    required this.newValue,
    required this.oldValue,
    this.type = 'PACKET_SIZE',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class BeginTransactionEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  Buffer newValue;
  Buffer oldValue;

  BeginTransactionEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onBeginTransaction',
    required this.newValue,
    required this.oldValue,
    this.type = 'BEGIN_TXN',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class CommitTransactionEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  Buffer newValue;
  Buffer oldValue;

  CommitTransactionEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onCommitTransaction',
    required this.newValue,
    required this.oldValue,
    this.type = 'COMMIT_TXN',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class RollbackTransactionEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  Buffer newValue;
  Buffer oldValue;

  RollbackTransactionEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onRollbackTransaction',
    required this.newValue,
    required this.oldValue,
    this.type = 'ROLLBACK_TXN',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class DatabaseMirroringPartnerEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  String newValue;
  String oldValue;

  DatabaseMirroringPartnerEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onDatabaseMirroringPartner',
    required this.newValue,
    required this.oldValue,
    this.type = 'DATABASE_MIRRORING_PARTNER',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class ResetConnectionEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  Buffer newValue;
  Buffer oldValue;

  ResetConnectionEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onResetConnection',
    required this.newValue,
    required this.oldValue,
    this.type = 'RESET_CONNECTION',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class CollationChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  Collation? newValue;
  Collation? oldValue;

  CollationChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onSqlCollationChange',
    required this.newValue,
    required this.oldValue,
    this.type = 'SQL_COLLATION',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

//to compensate for object literal
//manufacured class
class RoutingEnvChange {
  final String server;
  final num port;
  final num protocol;

  RoutingEnvChange({
    required this.server,
    required this.port,
    required this.protocol,
  });
}

class RoutingEnvChangeToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? type;
  RoutingEnvChange? newValue;
  Buffer? oldValue;

  RoutingEnvChangeToken({
    this.name = 'ENVCHANGE',
    this.handlerName = 'onRoutingChange',
    required this.newValue,
    required this.oldValue,
    this.type = 'ROUTING_CHANGE',
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class FeatureExtAckToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  bool? utf8Support;
  Buffer? fedAuth;

  FeatureExtAckToken({
    this.name = 'FEATUREEXTACK',
    this.handlerName = 'onFeatureExtAck',
    this.utf8Support,
    this.fedAuth,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class FedAuthInfoToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  String? spn;
  String? stsurl;

  FedAuthInfoToken({
    this.name = 'FEDAUTHINFO',
    this.handlerName = 'onFedAuthInfo',
    this.spn,
    this.stsurl,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class InfoMessageToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  final num number;
  final num state;
  final num clazz;
  final String message;
  final String serverName;
  final String procName;
  final num lineNumber;

  InfoMessageToken({
    this.name = 'INFO',
    this.handlerName = 'onInfoMessage',
    required this.number,
    required this.state,
    required this.clazz,
    required this.message,
    required this.serverName,
    required this.procName,
    required this.lineNumber,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class ErrorMessageToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  final num number;
  final num state;
  final num clazz;
  final String message;
  final String serverName;
  final String procName;
  final num lineNumber;

  ErrorMessageToken({
    this.name = 'ERROR',
    this.handlerName = 'onErrorMessage',
    required this.number,
    required this.state,
    required this.clazz,
    required this.message,
    required this.serverName,
    required this.procName,
    required this.lineNumber,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

//!objectLiteral class
class ProgVersion {
  final num major;
  final num minor;
  final num buildNumHi;
  final num buildNumLow;

  ProgVersion({
    required this.major,
    required this.minor,
    required this.buildNumHi,
    required this.buildNumLow,
  });
}

class LoginAckToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  ProgVersion progVersion;
  String interface;
  String tdsVersion;
  String progName;

  LoginAckToken({
    this.name = 'LOGINACK',
    this.handlerName = 'onLoginAck',
    required this.interface,
    required this.tdsVersion,
    required this.progName,
    required this.progVersion,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class NBCRowToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  dynamic columns;

  NBCRowToken({
    this.name = 'NBCROW',
    this.handlerName = 'onNBCRow',
    this.columns,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class OrderToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  List<num> columns;

  OrderToken({
    this.name = 'ORDER',
    this.handlerName = 'onOrder',
    required this.columns,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class ReturnStatusToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  num value;

  ReturnStatusToken({
    this.name = 'RETURNSTATUS',
    this.handlerName = 'onReturnStatus',
    required this.value,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class ReturnValueToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  dynamic value;
  num paramOrdinal;
  String paramName;
  Metadata metadata;

  ReturnValueToken({
    this.name = 'RETURNVALUE',
    this.handlerName = 'onReturnValue',
    this.value,
    required this.metadata,
    required this.paramName,
    required this.paramOrdinal,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class RowToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  dynamic columns;

  RowToken({
    this.name = 'ROW',
    this.handlerName = 'onRow',
    required this.columns,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}

class SSPIToken extends Token {
  @override
  String name;

  @override
  HandlerName handlerName;

  dynamic ntlmpacket;
  Buffer ntlmpacketBuffer;

  SSPIToken({
    this.name = 'SSPICHALLENGE',
    this.handlerName = 'onSSPI',
    this.ntlmpacket,
    required this.ntlmpacketBuffer,
  }) : super(
          name: name,
          handlerName: handlerName,
        );
}
