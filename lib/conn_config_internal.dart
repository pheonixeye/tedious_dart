import 'dart:io' show SecurityContext;

import 'package:tedious_dart/conn_const_typedef.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/conn_authentication.dart';

class InternalConnectionOptions {
  InternalConnectionOptions({
    this.abortTransactionOnError = false,
    this.appName,
    this.camelCaseColumns = false,
    this.cancelTimeout = DEFAULT_CANCEL_TIMEOUT,
    this.columnEncryptionKeyCacheTTL = 2 * 60 * 60 * 1000, // Units= miliseconds
    this.columnEncryptionSetting = false,
    this.columnNameReplacer,
    this.connectionRetryInterval = DEFAULT_CONNECT_RETRY_INTERVAL,
    this.connectTimeout = DEFAULT_CONNECT_TIMEOUT,
    this.connectionIsolationLevel = 0x02, //ISOLATION_LEVEL['READ_COMMITTED']!,
    this.cryptoCredentialsDetails,
    this.database,
    this.datefirst = DEFAULT_DATEFIRST,
    this.dateFormat = DEFAULT_DATEFORMAT,
    this.debug = const DebugOptions(),
    this.enableAnsiNull = true,
    this.enableAnsiNullDefault = true,
    this.enableAnsiPadding = true,
    this.enableAnsiWarnings = true,
    this.enableArithAbort = true,
    this.enableConcatNullYieldsNull = true,
    this.enableCursorCloseOnCommit,
    this.enableImplicitTransactions = false,
    this.enableNumericRoundabort = false,
    this.enableQuotedIdentifier = true,
    this.encrypt = true,
    this.fallbackToDefaultDb = false,
    this.encryptionKeyStoreProviders = const {},
    this.instanceName,
    this.isolationLevel = 0x02, //ISOLATION_LEVEL['READ_COMMITTED']!,
    this.language = DEFAULT_LANGUAGE,
    this.localAddress,
    this.maxRetriesOnTransientErrors = 3,
    this.multiSubnetFailover = false,
    this.packetSize = DEFAULT_PACKET_SIZE,
    this.port = DEFAULT_PORT,
    this.readOnlyIntent = false,
    this.requestTimeout = DEFAULT_CLIENT_REQUEST_TIMEOUT,
    this.rowCollectionOnDone = false,
    this.rowCollectionOnRequestCompletion = false,
    this.serverName,
    this.serverSupportsColumnEncryption = false,
    this.tdsVersion = DEFAULT_TDS_VERSION,
    this.textsize = DEFAULT_TEXTSIZE,
    this.trustedServerNameAE,
    this.trustServerCertificate = false,
    this.useColumnNames = false,
    this.useUTC = true,
    this.workstationId,
    this.lowerCaseGuids = false,
  });
  bool abortTransactionOnError;
  String? appName;
  bool camelCaseColumns;
  int cancelTimeout;
  int columnEncryptionKeyCacheTTL;
  bool columnEncryptionSetting;
  ColumnNameReplacer? columnNameReplacer;
  int connectionRetryInterval;
  int connectTimeout;
  int connectionIsolationLevel;
  SecurityContext? cryptoCredentialsDetails;
  String? database;
  int? datefirst;
  String? dateFormat;
  DebugOptions? debug;
  bool? enableAnsiNull;
  bool? enableAnsiNullDefault;
  bool? enableAnsiPadding;
  bool? enableAnsiWarnings;
  bool? enableArithAbort;
  bool? enableConcatNullYieldsNull;
  bool? enableCursorCloseOnCommit;
  bool? enableImplicitTransactions;
  bool? enableNumericRoundabort;
  bool? enableQuotedIdentifier;
  bool encrypt;
  KeyStoreProviderMap encryptionKeyStoreProviders;
  bool fallbackToDefaultDb;
  String? instanceName;
  int isolationLevel;
  String language;
  String? localAddress;
  int maxRetriesOnTransientErrors;
  bool multiSubnetFailover;
  int packetSize;
  int? port;
  bool readOnlyIntent;
  int requestTimeout;
  bool rowCollectionOnDone;
  bool rowCollectionOnRequestCompletion;
  String? serverName;
  bool serverSupportsColumnEncryption;
  String tdsVersion;
  int textsize;
  String? trustedServerNameAE;
  bool trustServerCertificate;
  bool useColumnNames;
  bool useUTC;
  String? workstationId;
  bool lowerCaseGuids;
}

class InternalConnectionConfig {
  String? server;
  InternalConnectionOptions? options;
  AuthenticationType? authentication;

  InternalConnectionConfig({
    required this.server,
    required this.options,
    required this.authentication,
  });
}
