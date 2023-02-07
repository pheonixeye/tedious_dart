// ignore_for_file: constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:node_interop/buffer.dart';
import 'package:node_interop/node_interop.dart';
import 'package:node_interop/stream.dart';
import 'package:tedious_dart/always_encrypted/keystore_provider_azure_key_vault.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/message_io.dart';
import 'package:tedious_dart/metadata_parser.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/packet.dart';
import 'package:tedious_dart/request.dart';
import 'package:tedious_dart/transaction.dart';
import 'package:tedious_dart/transient_error_lookup.dart';

typedef BeginTransactionCallback = void Function(
    {Error? err, Buffer? transactionDescriptor});

typedef SaveTransactionCallback = void Function({Error? err});

typedef CommitTransactionCallback = void Function({Error? err});

typedef RollbackTransactionCallback = void Function({Error? err});

typedef ResetCallback = void Function({Error? err});

typedef TransactionDoneCallback = void Function({Error? err, Map? args});

typedef CallbackParameters<T> = T? Function({Error? err, Map? args});

typedef TransactionDone<T> = void Function(
    {Error? err, T done, CallbackParameters<T> callbackParameters});

typedef TransactionCallback<T> = void Function(
    {Error? err, TransactionDone<T>? txDone});

const KEEP_ALIVE_INITIAL_DELAY = 30 * 1000;

const DEFAULT_CONNECT_TIMEOUT = 15 * 1000;

const DEFAULT_CLIENT_REQUEST_TIMEOUT = 15 * 1000;

const DEFAULT_CANCEL_TIMEOUT = 5 * 1000;

const DEFAULT_CONNECT_RETRY_INTERVAL = 500;

const DEFAULT_PACKET_SIZE = 4 * 1024;

const DEFAULT_TEXTSIZE = 2147483647;

const DEFAULT_DATEFIRST = 7;

const DEFAULT_PORT = 1433;

const DEFAULT_TDS_VERSION = '7_4';

const DEFAULT_LANGUAGE = 'us_english';

const DEFAULT_DATEFORMAT = 'mdy';

class _AuthOptions {
  String? clientId;
  String? token;
  String? userName;
  String? password;
  String? tenantId;
  String? clientSecret;
  String? domain;
  _AuthOptions({
    this.clientId,
    this.clientSecret,
    this.domain,
    this.password,
    this.tenantId,
    this.token,
    this.userName,
  });
}

abstract class _Authentication {
  String? get type;
  _AuthOptions? get options;
}

class AzureActiveDirectoryMsiAppServiceAuthentication extends _Authentication {
  AzureActiveDirectoryMsiAppServiceAuthentication({
    this.clientId,
  });
  final String? clientId;
  @override
  _AuthOptions get options => _AuthOptions(
        clientId: clientId,
      );

  @override
  String get type => 'azure-active-directory-msi-app-service';
}

class AzureActiveDirectoryMsiVmAuthentication extends _Authentication {
  AzureActiveDirectoryMsiVmAuthentication({
    this.clientId,
  });
  final String? clientId;
  @override
  _AuthOptions get options => _AuthOptions(
        clientId: clientId,
      );

  @override
  String get type => 'azure-active-directory-msi-vm';
}

class AzureActiveDirectoryDefaultAuthentication extends _Authentication {
  AzureActiveDirectoryDefaultAuthentication({
    this.clientId,
  });
  final String? clientId;
  @override
  _AuthOptions get options => _AuthOptions(
        clientId: clientId,
      );

  @override
  String get type => 'azure-active-directory-default';
}

class AzureActiveDirectoryAccessTokenAuthentication extends _Authentication {
  AzureActiveDirectoryAccessTokenAuthentication({
    this.token,
  });
  final String? token;
  @override
  _AuthOptions get options => _AuthOptions(
        token: token,
      );

  @override
  String get type => 'azure-active-directory-access-token';
}

class AzureActiveDirectoryPasswordAuthentication extends _Authentication {
  AzureActiveDirectoryPasswordAuthentication({
    this.userName,
    this.password,
    this.clientId,
    this.tenantId,
  });
  final String? userName;
  final String? password;
  final String? clientId;
  final String? tenantId;
  @override
  _AuthOptions get options => _AuthOptions(
        userName: userName,
        password: password,
        clientId: clientId,
        tenantId: tenantId,
      );

  @override
  String get type => 'azure-active-directory-password';
}

class AzureActiveDirectoryServicePrincipalSecret extends _Authentication {
  AzureActiveDirectoryServicePrincipalSecret({
    this.clientId,
    this.tenantId,
    this.clientSecret,
  });
  final String? clientId;
  final String? tenantId;
  final String? clientSecret;
  @override
  _AuthOptions get options => _AuthOptions(
        clientId: clientId,
        tenantId: tenantId,
        clientSecret: clientSecret,
      );

  @override
  String get type => 'azure-active-directory-service-principal-secret';
}

class NtlmAuthentication extends _Authentication {
  NtlmAuthentication({
    this.userName,
    this.password,
    this.domain,
  });
  final String? userName;
  final String? password;
  final String? domain;
  @override
  _AuthOptions get options => _AuthOptions(
        userName: userName,
        password: password,
        domain: domain,
      );

  @override
  String get type => 'ntlm';
}

class DefaultAuthentication extends _Authentication {
  DefaultAuthentication({
    this.userName,
    this.password,
  });
  final String? userName;
  final String? password;
  @override
  _AuthOptions get options => _AuthOptions(
        userName: userName,
        password: password,
      );

  @override
  String get type => 'default';
}

class ErrorWithCode extends MTypeError {
  final String code;
  ErrorWithCode(this.code) : super(code);
}

class InternalConnectionConfig {
  String? server;
  _Authentication? authentication;
  InternalConnectionOptions? options;

  InternalConnectionConfig({
    required this.server,
    required this.authentication,
    required this.options,
  });
}

class DebugOptions {
  bool? data;
  bool? packet;
  bool? payload;
  bool? token;
  DebugOptions({
    this.data,
    this.packet,
    this.payload,
    this.token,
  });
}

typedef ColumnNameReplacer = String? Function(
    {String? colName, num? index, Metadata? metadata});

class InternalConnectionOptions {
  InternalConnectionOptions(
      {required this.abortTransactionOnError,
      required this.appName,
      required this.camelCaseColumns,
      required this.cancelTimeout,
      required this.columnEncryptionKeyCacheTTL,
      required this.columnEncryptionSetting,
      required this.columnNameReplacer,
      required this.connectionRetryInterval,
      required this.connectTimeout,
      required this.cryptoCredentialsDetails,
      required this.database,
      required this.datefirst,
      required this.dateFormat,
      required this.debug,
      this.enableAnsiNull,
      this.enableAnsiNullDefault,
      this.enableAnsiPadding,
      this.enableAnsiWarnings,
      this.enableArithAbort,
      this.enableConcatNullYieldsNull,
      this.enableCursorCloseOnCommit,
      this.enableImplicitTransactions,
      this.enableNumericRoundabort,
      this.enableQuotedIdentifier,
      required this.encrypt,
      required this.encryptionKeyStoreProviders,
      required this.fallbackToDefaultDb,
      required this.instanceName,
      required this.language,
      this.localAddress,
      required this.maxRetriesOnTransientErrors,
      required this.multiSubnetFailover,
      required this.packetSize,
      this.port,
      required this.readOnlyIntent,
      required this.requestTimeout,
      required this.rowCollectionOnDone,
      required this.rowCollectionOnRequestCompletion,
      this.serverName,
      required this.serverSupportsColumnEncryption,
      required this.tdsVersion,
      required this.textsize,
      required this.trustedServerNameAE,
      required this.trustServerCertificate,
      required this.useColumnNames,
      required this.useUTC,
      this.workstationId,
      required this.lowerCaseGuids,
      required this.isolationLevel,
      required this.connectionIsolationLevel});
  bool abortTransactionOnError;
  String? appName;
  bool camelCaseColumns;
  num cancelTimeout;
  num columnEncryptionKeyCacheTTL;
  bool columnEncryptionSetting;
  ColumnNameReplacer? columnNameReplacer;
  num connectionRetryInterval;
  num connectTimeout;
  num connectionIsolationLevel;
  SecurityContext? cryptoCredentialsDetails;
  String? database;
  num? datefirst;
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
  num isolationLevel;
  String language;
  String? localAddress;
  num maxRetriesOnTransientErrors;
  bool multiSubnetFailover;
  num packetSize;
  num? port;
  bool readOnlyIntent;
  num requestTimeout;
  bool rowCollectionOnDone;
  bool rowCollectionOnRequestCompletion;
  String? serverName;
  bool serverSupportsColumnEncryption;
  String tdsVersion;
  num textsize;
  String? trustedServerNameAE;
  bool trustServerCertificate;
  bool useColumnNames;
  bool useUTC;
  String? workstationId;
  bool lowerCaseGuids;
}

typedef KeyStoreProviderMap
    = Map<String, ColumnEncryptionAzureKeyVaultProvider>;

//!objectLiteral class
// ignore: camel_case_types
abstract class _events {
  void socketError({Connection connection, Error err});
  void connectionTimeout({Connection connection});
  void message({Connection connection, Message message});
  void retry({Connection connection});
  void reconnect({Connection connection});
}

abstract class State {
  String? name;
  void enter({Connection connection});
  void exit({Connection connection, State newState});
  _events get events;

  State(this.name);
}

//TODO: ??
// ignore: non_constant_identifier_names
Map<String, State> STATES = {
  "INITIALIZED": State,
  "CONNECTING": State,
  "SENT_PRELOGIN": State,
  "REROUTING": State,
  "TRANSIENT_FAILURE_RETRY": State,
  "SENT_TLSSSLNEGOTIATION": State,
  "SENT_LOGIN7_WITH_STANDARD_LOGIN": State,
  "SENT_LOGIN7_WITH_NTLM": State,
  "SENT_LOGIN7_WITH_FEDAUTH": State,
  "LOGGED_IN_SENDING_INITIAL_SQL": State,
  "LOGGED_IN": State,
  "SENT_CLIENT_REQUEST": State,
  "SENT_ATTENTION": State,
  "FINAL": State,
};

// enum Authentication {
//   DefaultAuthentication('default'),
//   NtlmAuthentication('ntlm'),
//   AzureActiveDirectoryPasswordAuthentication('azure-active-directory-password'),
//   AzureActiveDirectoryMsiAppServiceAuthentication(
//       'azure-active-directory-msi-app-service'),
//   AzureActiveDirectoryMsiVmAuthentication('azure-active-directory-msi-vm'),
//   AzureActiveDirectoryAccessTokenAuthentication(
//       'azure-active-directory-access-token'),
//   AzureActiveDirectoryServicePrincipalSecret(
//       'azure-active-directory-service-principal-secret'),
//   AzureActiveDirectoryDefaultAuthentication('azure-active-directory-default');

//   final String type;
//   const Authentication(this.type);
// }

class AuthenticationType {
  late _Authentication? auth;
  String type;
  AuthenticationType(this.type);
  // switch (type) {
  //   case 'ntlm':
  //     auth = NtlmAuthentication();
  //     break;
  //   case 'azure-active-directory-password':
  //     auth = AzureActiveDirectoryPasswordAuthentication();
  //     break;
  //   case 'azure-active-directory-msi-app-service':
  //     auth = AzureActiveDirectoryMsiAppServiceAuthentication();
  //     break;
  //   case 'azure-active-directory-msi-vm':
  //     auth = AzureActiveDirectoryMsiVmAuthentication();
  //     break;
  //   case 'azure-active-directory-access-token':
  //     auth = AzureActiveDirectoryAccessTokenAuthentication();
  //     break;
  //   case 'azure-active-directory-service-principal-secret':
  //     auth = AzureActiveDirectoryServicePrincipalSecret();
  //     break;
  //   case 'azure-active-directory-default':
  //     auth = AzureActiveDirectoryDefaultAuthentication();
  //     break;
  //   case 'default':
  //     auth = DefaultAuthentication();
  //     break;
  //   default:
  //     auth = null;
  // }

}

class ConnectionConfiguration {
  String server;

  ConnectionOptions? options;

  AuthenticationOptions authentication;

  ConnectionConfiguration({
    required this.server,
    required this.authentication,
    this.options,
  });
}

class AuthenticationOptions {
  AuthenticationType? type;
  dynamic options;
  AuthenticationOptions({
    this.type,
    this.options,
  });
}

class ConnectionOptions {
  ConnectionOptions({
    required this.abortTransactionOnError,
    required this.appName,
    required this.camelCaseColumns,
    required this.cancelTimeout,
    required this.columnEncryptionKeyCacheTTL,
    required this.columnEncryptionSetting,
    required this.columnNameReplacer,
    required this.connectionRetryInterval,
    required this.connectTimeout,
    required this.cryptoCredentialsDetails,
    required this.database,
    required this.datefirst,
    required this.dateFormat,
    required this.debug,
    this.enableAnsiNull,
    this.enableAnsiNullDefault,
    this.enableAnsiPadding,
    this.enableAnsiWarnings,
    this.enableArithAbort,
    this.enableConcatNullYieldsNull,
    this.enableCursorCloseOnCommit,
    this.enableImplicitTransactions,
    this.enableNumericRoundabort,
    this.enableQuotedIdentifier,
    required this.encrypt,
    required this.encryptionKeyStoreProviders,
    required this.fallbackToDefaultDb,
    required this.instanceName,
    required this.language,
    this.localAddress,
    required this.maxRetriesOnTransientErrors,
    required this.multiSubnetFailover,
    required this.packetSize,
    this.port,
    required this.readOnlyIntent,
    required this.requestTimeout,
    required this.rowCollectionOnDone,
    required this.rowCollectionOnRequestCompletion,
    this.serverName,
    required this.serverSupportsColumnEncryption,
    required this.tdsVersion,
    required this.textsize,
    this.trustedServerNameAE,
    required this.trustServerCertificate,
    required this.useColumnNames,
    required this.useUTC,
    this.workstationId,
    required this.lowerCaseGuids,
    required this.isolationLevel,
    required this.connectionIsolationLevel,
  });
  bool abortTransactionOnError;
  String? appName;
  bool camelCaseColumns;
  num cancelTimeout;
  num columnEncryptionKeyCacheTTL;
  bool columnEncryptionSetting;
  ColumnNameReplacer? columnNameReplacer;
  num connectionRetryInterval;
  num connectTimeout;
  num connectionIsolationLevel;
  SecurityContext cryptoCredentialsDetails;
  String? database;
  num? datefirst;
  String? dateFormat;
  DebugOptions debug;
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
  String instanceName;
  num isolationLevel;
  String language;
  String? localAddress;
  num maxRetriesOnTransientErrors;
  bool multiSubnetFailover;
  num packetSize;
  num? port;
  bool readOnlyIntent;
  num requestTimeout;
  bool rowCollectionOnDone;
  bool rowCollectionOnRequestCompletion;
  String? serverName;
  bool serverSupportsColumnEncryption;
  String tdsVersion;
  num textsize;
  String? trustedServerNameAE;
  bool trustServerCertificate;
  bool useColumnNames;
  bool useUTC;
  String? workstationId;
  bool lowerCaseGuids;
}

const Map<String, int> CLEANUP_TYPE = {
  'NORMAL': 0,
  'REDIRECT': 1,
  'RETRY': 2,
};

class RoutingData {
  String server;
  num port;
  RoutingData({
    required this.server,
    required this.port,
  });
}

class Connection extends EventEmitter {
  late bool fedAuthRequired;

  InternalConnectionConfig? config;

  late SecurityContext secureContextOptions;

  late bool inTransaction;

  late List<Buffer> transactionDescriptors;

  late num transactionDepth;

  late bool isSqlBatch;

  late num curTransientRetryCount;

  late TransientErrorLookup transientErrorLookup;

  late bool closed;

  Error? loginError;
  //  null | AggregateError | ConnectionError;

  late Debug debug;

  dynamic ntlmpacket;

  Buffer? ntlmpacketBuffer;

  // ignore: non_constant_identifier_names
  Map<String, State> STATE = STATES;

  RoutingData? routingData;

  late MessageIO messageIo;

  late State state;

  bool? resetConnectionOnNextRequest;

  dynamic request;
  //  null | Request | BulkLoad;

  dynamic procReturnStatusValue;

  Socket? socket;

  late Buffer messageBuffer;

  Timer? connectTimer;

  Timer? cancelTimer;

  Timer? requestTimer;

  Timer? retryTimer;

  //todo
  late Function(dynamic)? _cancelAfterRequestSent;

  Collation? databaseCollation;

  Connection(this.config) : super() {
    //
    if (config.runtimeType != Object || config == null) {
      throw MTypeError(
          'The "config" argument is required and must be of type Object.');
    }

    if (config!.server.runtimeType != String) {
      throw MTypeError(
          'The "config.server" property is required and must be of type string.');
    }

    fedAuthRequired = false;

    AuthenticationType authentication;
    if (config!.authentication != null) {
      if (config!.authentication.runtimeType != Object ||
          config!.authentication == null) {
        throw MTypeError(
            'The "config.authentication" property must be of type Object.');
      }

      var type = config!.authentication!.type;
      var options = config!.authentication!.options;

      if (type.runtimeType != String) {
        throw MTypeError(
            'The "config.authentication.type" property must be of type string.');
      }
      if (type != 'default' &&
          type != 'ntlm' &&
          type != 'azure-active-directory-password' &&
          type != 'azure-active-directory-access-token' &&
          type != 'azure-active-directory-msi-vm' &&
          type != 'azure-active-directory-msi-app-service' &&
          type != 'azure-active-directory-service-principal-secret' &&
          type != 'azure-active-directory-default') {
        throw MTypeError(
            'The "type" property must one of "default", "ntlm", "azure-active-directory-password", "azure-active-directory-access-token", "azure-active-directory-default", "azure-active-directory-msi-vm" or "azure-active-directory-msi-app-service" or "azure-active-directory-service-principal-secret".');
      }
      if (options.runtimeType != Object || options == null) {
        throw MTypeError(
            'The "config.authentication.options" property must be of type object.');
      }
      //!
      if (type == 'ntlm') {
        if (options.domain.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.domain" property must be of type string.');
        }

        if (options.userName != null &&
            options.userName.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.userName" property must be of type string.');
        }

        if (options.password != null &&
            options.password.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.password" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = NtlmAuthentication(
            userName: options.userName,
            password: options.password,
            domain: options.domain,
          );
      }
      //!
      else if (type == 'azure-active-directory-password') {
        if (options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }

        if (options.userName != null &&
            options.userName.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.userName" property must be of type string.');
        }

        if (options.password != null &&
            options.password.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.password" property must be of type string.');
        }

        if (options.tenantId != null &&
            options.tenantId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.tenantId" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = AzureActiveDirectoryPasswordAuthentication(
            userName: options.userName,
            password: options.password,
            clientId: options.clientId,
            tenantId: options.tenantId,
          );
      }
      //!
      else if (type == 'azure-active-directory-access-token') {
        if (options.token.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.token" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = AzureActiveDirectoryAccessTokenAuthentication(
            token: options.token,
          );
      }
      //!
      else if (type == 'azure-active-directory-msi-vm') {
        if (options.clientId != null &&
            options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = AzureActiveDirectoryMsiAppServiceAuthentication(
            clientId: options.clientId,
          );
      }
      //!
      else if (type == 'azure-active-directory-default') {
        if (options.clientId != null &&
            options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = AzureActiveDirectoryDefaultAuthentication(
            clientId: options.clientId,
          );
      }
      //!
      else if (type == 'azure-active-directory-msi-app-service') {
        if (options.clientId != null &&
            options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = AzureActiveDirectoryMsiAppServiceAuthentication(
            clientId: options.clientId,
          );
      }
      //!
      else if (type == 'azure-active-directory-service-principal-secret') {
        if (options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }

        if (options.clientSecret.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientSecret" property must be of type string.');
        }

        if (options.tenantId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.tenantId" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = AzureActiveDirectoryServicePrincipalSecret(
            clientId: options.clientId,
            clientSecret: options.clientSecret,
            tenantId: options.tenantId,
          );
      }
      //!
      else {
        if (options.userName != null &&
            options.userName.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.userName" property must be of type string.');
        }

        if (options.password != null &&
            options.password.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.password" property must be of type string.');
        }
        authentication = AuthenticationType(type!)
          ..auth = DefaultAuthentication(
            userName: options.userName,
            password: options.password,
          );
      }
    } else {
      authentication = AuthenticationType('default')
        ..auth = DefaultAuthentication(
          userName: null,
          password: null,
        );
    }
    config = InternalConnectionConfig(
      server: config!.server,
      authentication: authentication.auth,
      options: InternalConnectionOptions(
        abortTransactionOnError: false,
        appName: null,
        camelCaseColumns: false,
        cancelTimeout: DEFAULT_CANCEL_TIMEOUT,
        columnEncryptionKeyCacheTTL: 2 * 60 * 60 * 1000, // Units: miliseconds
        columnEncryptionSetting: false,
        columnNameReplacer: null,
        connectionRetryInterval: DEFAULT_CONNECT_RETRY_INTERVAL,
        connectTimeout: DEFAULT_CONNECT_TIMEOUT,
        connectionIsolationLevel: ISOLATION_LEVEL['READ_COMMITTED']!,
        cryptoCredentialsDetails: SecurityContext(),
        database: null,
        datefirst: DEFAULT_DATEFIRST,
        dateFormat: DEFAULT_DATEFORMAT,
        debug: DebugOptions(
          data: false,
          packet: false,
          payload: false,
          token: false,
        ),
        enableAnsiNull: true,
        enableAnsiNullDefault: true,
        enableAnsiPadding: true,
        enableAnsiWarnings: true,
        enableArithAbort: true,
        enableConcatNullYieldsNull: true,
        enableCursorCloseOnCommit: null,
        enableImplicitTransactions: false,
        enableNumericRoundabort: false,
        enableQuotedIdentifier: true,
        encrypt: true,
        fallbackToDefaultDb: false,
        encryptionKeyStoreProviders: {},
        instanceName: null,
        isolationLevel: ISOLATION_LEVEL['READ_COMMITTED']!,
        language: DEFAULT_LANGUAGE,
        localAddress: null,
        maxRetriesOnTransientErrors: 3,
        multiSubnetFailover: false,
        packetSize: DEFAULT_PACKET_SIZE,
        port: DEFAULT_PORT,
        readOnlyIntent: false,
        requestTimeout: DEFAULT_CLIENT_REQUEST_TIMEOUT,
        rowCollectionOnDone: false,
        rowCollectionOnRequestCompletion: false,
        serverName: null,
        serverSupportsColumnEncryption: false,
        tdsVersion: DEFAULT_TDS_VERSION,
        textsize: DEFAULT_TEXTSIZE,
        trustedServerNameAE: null,
        trustServerCertificate: false,
        useColumnNames: false,
        useUTC: true,
        workstationId: null,
        lowerCaseGuids: false,
      ),
    );
    //! i think that these are useless type checks
    if (config!.options != null) {
      if (config!.options!.port != null &&
          config!.options!.instanceName != null) {
        throw MTypeError(
            'Port and instanceName are mutually exclusive, but   ${config!.options!.port}  and   ${config!.options!.instanceName}  provided');
      }

      if (config!.options!.abortTransactionOnError != null) {
        if (config!.options!.abortTransactionOnError is! bool &&
            config!.options!.abortTransactionOnError != null) {
          throw MTypeError(
              'The "config!.options!.abortTransactionOnError" property must be of type string or null.');
        }

        this.config!.options!.abortTransactionOnError =
            config!.options!.abortTransactionOnError;
      }

      if (config!.options!.appName != null) {
        if (config!.options!.appName is! String) {
          throw MTypeError(
              'The "config!.options!.appName" property must be of type string.');
        }

        this.config!.options!.appName = config!.options!.appName;
      }

      if (config!.options!.camelCaseColumns != null) {
        if (config!.options!.camelCaseColumns is! bool) {
          throw MTypeError(
              'The "config!.options!.camelCaseColumns" property must be of type boolean.');
        }

        this.config!.options!.camelCaseColumns =
            config!.options!.camelCaseColumns;
      }

      if (config!.options!.cancelTimeout != null) {
        if (config!.options!.cancelTimeout is! num) {
          throw MTypeError(
              'The "config!.options!.cancelTimeout" property must be of type number.');
        }

        this.config!.options!.cancelTimeout = config!.options!.cancelTimeout;
      }

      if (config!.options!.columnNameReplacer != null) {
        if (config!.options!.columnNameReplacer is! Function) {
          throw MTypeError(
              'The "config!.options!.cancelTimeout" property must be of type function.');
        }

        this.config!.options!.columnNameReplacer =
            config!.options!.columnNameReplacer;
      }

      if (config!.options!.connectionIsolationLevel != null) {
        assertValidIsolationLevel(config!.options!.connectionIsolationLevel,
            'config!.options!.connectionIsolationLevel');

        this.config!.options!.connectionIsolationLevel =
            config!.options!.connectionIsolationLevel;
      }

      if (config!.options!.connectTimeout != null) {
        if (config!.options!.connectTimeout is! num) {
          throw MTypeError(
              'The "config!.options!.connectTimeout" property must be of type number.');
        }

        this.config!.options!.connectTimeout = config!.options!.connectTimeout;
      }

      if (config!.options!.cryptoCredentialsDetails != null) {
        if (config!.options!.cryptoCredentialsDetails is! SecurityContext ||
            config!.options!.cryptoCredentialsDetails == null) {
          throw MTypeError(
              'The "config!.options!.cryptoCredentialsDetails" property must be of type Object.');
        }

        this.config!.options!.cryptoCredentialsDetails =
            config!.options!.cryptoCredentialsDetails;
      }

      if (config!.options!.database != null) {
        if (config!.options!.database is! String) {
          throw MTypeError(
              'The "config!.options!.database" property must be of type string.');
        }

        this.config!.options!.database = config!.options!.database;
      }

      if (config!.options!.datefirst != null) {
        if (config!.options!.datefirst is! num &&
            config!.options!.datefirst != null) {
          throw MTypeError(
              'The "config!.options!.datefirst" property must be of type number.');
        }

        if (config!.options!.datefirst != null &&
            (config!.options!.datefirst! < 1 ||
                config!.options!.datefirst! > 7)) {
          throw RangeError(
              'The "config!.options!.datefirst" property must be >= 1 and <= 7');
        }

        this.config!.options!.datefirst = config!.options!.datefirst;
      }

      if (config!.options!.dateFormat != null) {
        if (config!.options!.dateFormat is! String &&
            config!.options!.dateFormat != null) {
          throw MTypeError(
              'The "config!.options!.dateFormat" property must be of type string or null.');
        }

        this.config!.options!.dateFormat = config!.options!.dateFormat;
      }

      if (config!.options!.debug != null) {
        if (config!.options!.debug!.data != null) {
          if (config!.options!.debug!.data is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.data" property must be of type boolean.');
          }

          this.config!.options!.debug!.data = config!.options!.debug!.data;
        }

        if (config!.options!.debug!.packet != null) {
          if (config!.options!.debug!.packet is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.packet" property must be of type boolean.');
          }

          this.config!.options!.debug!.packet = config!.options!.debug!.packet;
        }

        if (config!.options!.debug!.payload != null) {
          if (config!.options!.debug!.payload is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.payload" property must be of type boolean.');
          }

          this.config!.options!.debug!.payload =
              config!.options!.debug!.payload;
        }

        if (config!.options!.debug!.token != null) {
          if (config!.options!.debug!.token is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.token" property must be of type boolean.');
          }

          this.config!.options!.debug!.token = config!.options!.debug!.token;
        }
      }

      if (config!.options!.enableAnsiNull != null) {
        if (config!.options!.enableAnsiNull is! bool &&
            config!.options!.enableAnsiNull != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiNull" property must be of type boolean or null.');
        }

        this.config!.options!.enableAnsiNull = config!.options!.enableAnsiNull;
      }

      if (config!.options!.enableAnsiNullDefault != null) {
        if (config!.options!.enableAnsiNullDefault is! bool &&
            config!.options!.enableAnsiNullDefault != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiNullDefault" property must be of type boolean or null.');
        }

        this.config!.options!.enableAnsiNullDefault =
            config!.options!.enableAnsiNullDefault;
      }

      if (config!.options!.enableAnsiPadding != null) {
        if (config!.options!.enableAnsiPadding is! bool &&
            config!.options!.enableAnsiPadding != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiPadding" property must be of type boolean or null.');
        }

        this.config!.options!.enableAnsiPadding =
            config!.options!.enableAnsiPadding;
      }

      if (config!.options!.enableAnsiWarnings != null) {
        if (config!.options!.enableAnsiWarnings is! bool &&
            config!.options!.enableAnsiWarnings != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiWarnings" property must be of type boolean or null.');
        }

        this.config!.options!.enableAnsiWarnings =
            config!.options!.enableAnsiWarnings;
      }

      if (config!.options!.enableArithAbort != null) {
        if (config!.options!.enableArithAbort is! bool &&
            config!.options!.enableArithAbort != null) {
          throw MTypeError(
              'The "config!.options!.enableArithAbort" property must be of type boolean or null.');
        }

        this.config!.options!.enableArithAbort =
            config!.options!.enableArithAbort;
      }

      if (config!.options!.enableConcatNullYieldsNull != null) {
        if (config!.options!.enableConcatNullYieldsNull is! bool &&
            config!.options!.enableConcatNullYieldsNull != null) {
          throw MTypeError(
              'The "config!.options!.enableConcatNullYieldsNull" property must be of type boolean or null.');
        }

        this.config!.options!.enableConcatNullYieldsNull =
            config!.options!.enableConcatNullYieldsNull;
      }

      if (config!.options!.enableCursorCloseOnCommit != null) {
        if (config!.options!.enableCursorCloseOnCommit is! bool &&
            config!.options!.enableCursorCloseOnCommit != null) {
          throw MTypeError(
              'The "config!.options!.enableCursorCloseOnCommit" property must be of type boolean or null.');
        }

        this.config!.options!.enableCursorCloseOnCommit =
            config!.options!.enableCursorCloseOnCommit;
      }

      if (config!.options!.enableImplicitTransactions != null) {
        if (config!.options!.enableImplicitTransactions is! bool &&
            config!.options!.enableImplicitTransactions != null) {
          throw MTypeError(
              'The "config!.options!.enableImplicitTransactions" property must be of type boolean or null.');
        }

        this.config!.options!.enableImplicitTransactions =
            config!.options!.enableImplicitTransactions;
      }

      if (config!.options!.enableNumericRoundabort != null) {
        if (config!.options!.enableNumericRoundabort is! bool &&
            config!.options!.enableNumericRoundabort != null) {
          throw MTypeError(
              'The "config!.options!.enableNumericRoundabort" property must be of type boolean or null.');
        }

        this.config!.options!.enableNumericRoundabort =
            config!.options!.enableNumericRoundabort;
      }

      if (config!.options!.enableQuotedIdentifier != null) {
        if (config!.options!.enableQuotedIdentifier is! bool &&
            config!.options!.enableQuotedIdentifier != null) {
          throw MTypeError(
              'The "config!.options!.enableQuotedIdentifier" property must be of type boolean or null.');
        }

        this.config!.options!.enableQuotedIdentifier =
            config!.options!.enableQuotedIdentifier;
      }

      if (config!.options!.encrypt != null) {
        if (config!.options!.encrypt is! bool) {
          throw MTypeError(
              'The "config!.options!.encrypt" property must be of type boolean.');
        }

        this.config!.options!.encrypt = config!.options!.encrypt;
      }

      if (config!.options!.fallbackToDefaultDb != null) {
        if (config!.options!.fallbackToDefaultDb is! bool) {
          throw MTypeError(
              'The "config!.options!.fallbackToDefaultDb" property must be of type boolean.');
        }

        this.config!.options!.fallbackToDefaultDb =
            config!.options!.fallbackToDefaultDb;
      }

      if (config!.options!.instanceName != null) {
        if (config!.options!.instanceName is! String) {
          throw MTypeError(
              'The "config!.options!.instanceName" property must be of type string.');
        }

        this.config!.options!.instanceName = config!.options!.instanceName;
        this.config!.options!.port = null;
      }

      if (config!.options!.isolationLevel != null) {
        assertValidIsolationLevel(
            config!.options!.isolationLevel, 'config!.options!.isolationLevel');

        this.config!.options!.isolationLevel = config!.options!.isolationLevel;
      }

      if (config!.options!.language != null) {
        if (config!.options!.language is! String &&
            config!.options!.language != null) {
          throw MTypeError(
              'The "config!.options!.language" property must be of type string or null.');
        }

        this.config!.options!.language = config!.options!.language;
      }

      if (config!.options!.localAddress != null) {
        if (config!.options!.localAddress is! String) {
          throw MTypeError(
              'The "config!.options!.localAddress" property must be of type string.');
        }

        this.config!.options!.localAddress = config!.options!.localAddress;
      }

      if (config!.options!.multiSubnetFailover != null) {
        if (config!.options!.multiSubnetFailover is! bool) {
          throw MTypeError(
              'The "config!.options!.multiSubnetFailover" property must be of type boolean.');
        }

        this.config!.options!.multiSubnetFailover =
            config!.options!.multiSubnetFailover;
      }

      if (config!.options!.packetSize != null) {
        if (config!.options!.packetSize is! num) {
          throw MTypeError(
              'The "config!.options!.packetSize" property must be of type number.');
        }

        this.config!.options!.packetSize = config!.options!.packetSize;
      }

      if (config!.options!.port != null) {
        if (config!.options!.port is! num) {
          throw MTypeError(
              'The "config!.options!.port" property must be of type number.');
        }

        if (config!.options!.port! <= 0 || config!.options!.port! >= 65536) {
          throw RangeError(
              'The "config!.options!.port" property must be > 0 and < 65536');
        }

        this.config!.options!.port = config!.options!.port;
        this.config!.options!.instanceName = null;
      }

      if (config!.options!.readOnlyIntent != null) {
        if (config!.options!.readOnlyIntent is! bool) {
          throw MTypeError(
              'The "config!.options!.readOnlyIntent" property must be of type boolean.');
        }

        this.config!.options!.readOnlyIntent = config!.options!.readOnlyIntent;
      }

      if (config!.options!.requestTimeout != null) {
        if (config!.options!.requestTimeout is! num) {
          throw MTypeError(
              'The "config!.options!.requestTimeout" property must be of type number.');
        }

        this.config!.options!.requestTimeout = config!.options!.requestTimeout;
      }

      if (config!.options!.maxRetriesOnTransientErrors != null) {
        if (config!.options!.maxRetriesOnTransientErrors is! num) {
          throw MTypeError(
              'The "config!.options!.maxRetriesOnTransientErrors" property must be of type number.');
        }

        if (config!.options!.maxRetriesOnTransientErrors < 0) {
          throw MTypeError(
              'The "config!.options!.maxRetriesOnTransientErrors" property must be equal or greater than 0.');
        }

        this.config!.options!.maxRetriesOnTransientErrors =
            config!.options!.maxRetriesOnTransientErrors;
      }

      if (config!.options!.connectionRetryInterval != null) {
        if (config!.options!.connectionRetryInterval is! num) {
          throw MTypeError(
              'The "config!.options!.connectionRetryInterval" property must be of type number.');
        }

        if (config!.options!.connectionRetryInterval <= 0) {
          throw MTypeError(
              'The "config!.options!.connectionRetryInterval" property must be greater than 0.');
        }

        this.config!.options!.connectionRetryInterval =
            config!.options!.connectionRetryInterval;
      }

      if (config!.options!.rowCollectionOnDone != null) {
        if (config!.options!.rowCollectionOnDone is! bool) {
          throw MTypeError(
              'The "config!.options!.rowCollectionOnDone" property must be of type boolean.');
        }

        this.config!.options!.rowCollectionOnDone =
            config!.options!.rowCollectionOnDone;
      }

      if (config!.options!.rowCollectionOnRequestCompletion != null) {
        if (config!.options!.rowCollectionOnRequestCompletion is! bool) {
          throw MTypeError(
              'The "config!.options!.rowCollectionOnRequestCompletion" property must be of type boolean.');
        }

        this.config!.options!.rowCollectionOnRequestCompletion =
            config!.options!.rowCollectionOnRequestCompletion;
      }

      if (config!.options!.tdsVersion != null) {
        if (config!.options!.tdsVersion is! String) {
          throw MTypeError(
              'The "config!.options!.tdsVersion" property must be of type string.');
        }

        this.config!.options!.tdsVersion = config!.options!.tdsVersion;
      }

      if (config!.options!.textsize != null) {
        if (config!.options!.textsize is! num &&
            config!.options!.textsize != null) {
          throw MTypeError(
              'The "config!.options!.textsize" property must be of type number or null.');
        }

        if (config!.options!.textsize > 2147483647) {
          throw MTypeError(
              'The "config!.options!.textsize" can\'t be greater than 2147483647.');
        } else if (config!.options!.textsize < -1) {
          throw MTypeError(
              'The "config!.options!.textsize" can\'t be smaller than -1.');
        }

        this.config!.options!.textsize = config!.options!.textsize; //TODO |0
      }

      if (config!.options!.trustServerCertificate != null) {
        if (config!.options!.trustServerCertificate is! bool) {
          throw MTypeError(
              'The "config!.options!.trustServerCertificate" property must be of type boolean.');
        }

        this.config!.options!.trustServerCertificate =
            config!.options!.trustServerCertificate;
      }

      if (config!.options!.useColumnNames != null) {
        if (config!.options!.useColumnNames is! bool) {
          throw MTypeError(
              'The "config!.options!.useColumnNames" property must be of type boolean.');
        }

        this.config!.options!.useColumnNames = config!.options!.useColumnNames;
      }

      if (config!.options!.useUTC != null) {
        if (config!.options!.useUTC is! bool) {
          throw MTypeError(
              'The "config!.options!.useUTC" property must be of type boolean.');
        }

        this.config!.options!.useUTC = config!.options!.useUTC;
      }

      if (config!.options!.workstationId != null) {
        if (config!.options!.workstationId != 'string') {
          throw MTypeError(
              'The "config!.options!.workstationId" property must be of type string.');
        }

        this.config!.options!.workstationId = config!.options!.workstationId;
      }

      if (config!.options!.lowerCaseGuids != null) {
        if (config!.options!.lowerCaseGuids is! bool) {
          throw MTypeError(
              'The "config!.options!.lowerCaseGuids" property must be of type boolean.');
        }

        this.config!.options!.lowerCaseGuids = config!.options!.lowerCaseGuids;
      }
    }
    this.debug = this.createDebug();
    this.inTransaction = false;
    this.transactionDescriptors = [
      Buffer.from([0, 0, 0, 0, 0, 0, 0, 0])
    ];

    // 'beginTransaction', 'commitTransaction' and 'rollbackTransaction'
    // events are utilized to maintain inTransaction property state which in
    // turn is used in managing transactions. These events are only fired for
    // TDS version 7.2 and beyond. The properties below are used to emulate
    // equivalent behavior for TDS versions before 7.2.
    this.transactionDepth = 0;
    this.isSqlBatch = false;
    this.closed = false;
    this.messageBuffer = Buffer.alloc(0);

    this.curTransientRetryCount = 0;
    this.transientErrorLookup = TransientErrorLookup();

    this.state = this.STATE['INITIALIZED'];

    this._cancelAfterRequestSent = () {
      this.messageIo.sendMessage(TYPE['ATTENTION']!);
      this.createCancelTimer();
    };
    //TODO! end of constructor
  }
  //TODO! end of constructor

  makeRequest(Request request, num packetType, Stream<Buffer> payload,
      {String Function(String indent)? toString}) {
    if (this.state != this.STATE['LOGGED_IN']) {
      var message =
          'Requests can only be made in the ${this.STATE['LOGGED_IN']!.name} state, not the ${this.state.name} state';
      this.debug.log(message);
      request.callback(RequestError(message, 'EINVALIDSTATE'));
    } else if (request.canceled) {
      process.nextTick(() {
        request.callback(RequestError('Canceled.', 'ECANCEL'));
      });
    } else {
      if (packetType == TYPE['SQL_BATCH']) {
        this.isSqlBatch = true;
      } else {
        this.isSqlBatch = false;
      }

      var message = Message(
          type: packetType as int,
          resetConnection: this.resetConnectionOnNextRequest!);
      //TODO: better message implementation
      //TODO: redo message & IO implementation
      //ignore:undefined_method
      var payloadStream = Readable.from(payload);

      this.request = request;
      request.connection = this;
      request.rowCount = 0;
      request.rows = [];
      request.rst = [];

      dynamic onCancel() {
        payloadStream.unpipe(message);
        payloadStream.destroy(RequestError('Canceled.', 'ECANCEL'));

        // set the ignore bit and end the message.
        message.ignore = true;
        message.end();

        if (request is Request && request.paused) {
          // resume the request if it was paused so we can read the remaining tokens
          request.resume();
        }
      }

      request.once('cancel', onCancel());

      this.createRequestTimer();

      this
          .messageIo
          .outgoingMessageStream!
          .write(message, 'utf-8', ([error]) {});
      this.transitionTo(this.STATE['SENT_CLIENT_REQUEST']);

      message.once('finish', (data) {
        request.removeEventListener(
            EventListener('cancel', (val) {}, onCancel: onCancel));
        request.once('cancel', this._cancelAfterRequestSent);

        this.resetConnectionOnNextRequest = false;
        this.debug.payload(() {
          return payload.toString();
        });
      });

      payloadStream.once('error', (error) {
        payloadStream.unpipe(message);

        // Only set a request error if no error was set yet.
        request.error ??= error;

        message.ignore = true;
        message.end();
      });
      payloadStream.pipe(message);
    }
  }

  cancel() {
    if (!this.request) {
      return false;
    }
    if (this.request.canceled) {
      return false;
    }
    this.request.cancel();
    return true;
  }

  reset(ResetCallback callback) {
    var request = Request(
        sqlTextOrProcedure: this.getInitialSql(),
        callback: ([err, rowCount, rows]) {
          if (this.config!.options!.tdsVersion != '7_2')
          //TODO: 'String < '7_2''
          {
            this.inTransaction = false;
          }
          callback(err: err);
        });
    resetConnectionOnNextRequest = true;
    execSqlBatch(request);
  }

  currentTransactionDescriptor() {
    return transactionDescriptors[transactionDescriptors.length - 1];
  }

  String getIsolationLevelText(num isolationLevel) {
    if (isolationLevel == ISOLATION_LEVEL['READ_UNCOMMITTED']!) {
      return 'read uncommitted';
    }

    if (isolationLevel == ISOLATION_LEVEL['REPEATABLE_READ']!) {
      return 'repeatable read';
    }

    if (isolationLevel == ISOLATION_LEVEL['SERIALIZABLE']!) {
      return 'serializable';
    }

    if (isolationLevel == ISOLATION_LEVEL['SNAPSHOT']!) {
      return 'snapshot';
    }

    return 'read committed';
  }

  //TODO! end of class
}

bool isTransientError(dynamic error) {
  //error ==>> ConnectionError | AggregateError
  if (error is! ConnectionError) {
    error = error.errors[0];
  }
  return (error is ConnectionError) && !error.isTransient!;
}
