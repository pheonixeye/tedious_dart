// ignore_for_file: constant_identifier_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:eventify/eventify.dart';
import 'package:node_interop/buffer.dart';
import 'package:tedious_dart/always_encrypted/keystore_provider_azure_key_vault.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/message_io.dart';
import 'package:tedious_dart/metadata_parser.dart';
import 'package:tedious_dart/models/errors.dart';
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

abstract class InternalConnectionOptions {
  bool get abortTransactionOnError;
  String? get appName;
  bool get camelCaseColumns;
  num get cancelTimeout;
  num get columnEncryptionKeyCacheTTL;
  bool get columnEncryptionSetting;
  String? columnNameReplacer({
    String colName,
    num index,
    Metadata metadata,
  });
  num get connectionRetryInterval;
  num get connectTimeout;
  // connectionIsolationLevel: typeof ISOLATION_LEVEL[keyof typeof ISOLATION_LEVEL];
  //TODO
  SecurityContext get cryptoCredentialsDetails;
  String? get database;
  num get datefirst;
  String get dateFormat;
  DebugOptions get debug;
  bool? get enableAnsiNull;
  bool? get enableAnsiNullDefault;
  bool? get enableAnsiPadding;
  bool? get enableAnsiWarnings;
  bool? get enableArithAbort;
  bool? get enableConcatNullYieldsNull;
  bool? get enableCursorCloseOnCommit;
  bool? get enableImplicitTransactions;
  bool? get enableNumericRoundabort;
  bool? get enableQuotedIdentifier;
  bool get encrypt;
  KeyStoreProviderMap get encryptionKeyStoreProviders;
  bool get fallbackToDefaultDb;
  String get instanceName;
  // isolationLevel: typeof ISOLATION_LEVEL[keyof typeof ISOLATION_LEVEL];
  String get language;
  String? get localAddress;
  num get maxRetriesOnTransientErrors;
  bool get multiSubnetFailover;
  num get packetSize;
  num? get port;
  bool get readOnlyIntent;
  num get requestTimeout;
  bool get rowCollectionOnDone;
  bool get rowCollectionOnRequestCompletion;
  String? get serverName;
  bool get serverSupportsColumnEncryption;
  String get tdsVersion;
  num get textsize;
  String get trustedServerNameAE;
  bool get trustServerCertificate;
  bool get useColumnNames;
  bool get useUTC;
  String? get workstationId;
  bool get lowerCaseGuids;
}

abstract class KeyStoreProviderMap {
  Map<String, ColumnEncryptionAzureKeyVaultProvider> get data;
}

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
  String? get name;
  void enter({Connection connection});
  void exit({Connection connection, State newState});
  _events get events;
}

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
  AuthenticationType(this.type) {
    switch (type) {
      case 'ntlm':
        auth = NtlmAuthentication();
        break;
      case 'azure-active-directory-password':
        auth = AzureActiveDirectoryPasswordAuthentication();
        break;
      case 'azure-active-directory-msi-app-service':
        auth = AzureActiveDirectoryMsiAppServiceAuthentication();
        break;
      case 'azure-active-directory-msi-vm':
        auth = AzureActiveDirectoryMsiVmAuthentication();
        break;
      case 'azure-active-directory-access-token':
        auth = AzureActiveDirectoryAccessTokenAuthentication();
        break;
      case 'azure-active-directory-service-principal-secret':
        auth = AzureActiveDirectoryServicePrincipalSecret();
        break;
      case 'azure-active-directory-default':
        auth = AzureActiveDirectoryDefaultAuthentication();
        break;
      case 'default':
        auth = DefaultAuthentication();
        break;
      default:
        auth = null;
    }
  }
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

abstract class ConnectionOptions {
  bool get abortTransactionOnError;
  String? get appName;
  bool get camelCaseColumns;
  num get cancelTimeout;
  num get columnEncryptionKeyCacheTTL;
  bool get columnEncryptionSetting;
  String? columnNameReplacer({
    String colName,
    num index,
    Metadata metadata,
  });
  num get connectionRetryInterval;
  num get connectTimeout;
  // connectionIsolationLevel: typeof ISOLATION_LEVEL[keyof typeof ISOLATION_LEVEL];
  //TODO
  SecurityContext get cryptoCredentialsDetails;
  String? get database;
  num get datefirst;
  String get dateFormat;
  DebugOptions get debug;
  bool? get enableAnsiNull;
  bool? get enableAnsiNullDefault;
  bool? get enableAnsiPadding;
  bool? get enableAnsiWarnings;
  bool? get enableArithAbort;
  bool? get enableConcatNullYieldsNull;
  bool? get enableCursorCloseOnCommit;
  bool? get enableImplicitTransactions;
  bool? get enableNumericRoundabort;
  bool? get enableQuotedIdentifier;
  bool get encrypt;
  KeyStoreProviderMap get encryptionKeyStoreProviders;
  bool get fallbackToDefaultDb;
  String get instanceName;
  // isolationLevel: typeof ISOLATION_LEVEL[keyof typeof ISOLATION_LEVEL];
  String get language;
  String? get localAddress;
  num get maxRetriesOnTransientErrors;
  bool get multiSubnetFailover;
  num get packetSize;
  num? get port;
  bool get readOnlyIntent;
  num get requestTimeout;
  bool get rowCollectionOnDone;
  bool get rowCollectionOnRequestCompletion;
  String? get serverName;
  bool get serverSupportsColumnEncryption;
  String get tdsVersion;
  num get textsize;
  String get trustedServerNameAE;
  bool get trustServerCertificate;
  bool get useColumnNames;
  bool get useUTC;
  String? get workstationId;
  bool get lowerCaseGuids;
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
  bool fedAuthRequired;

  InternalConnectionConfig? config;

  SecurityContext secureContextOptions;

  bool inTransaction;

  List<Buffer> transactionDescriptors;

  num transactionDepth;

  bool isSqlBatch;

  num curTransientRetryCount;

  TransientErrorLookup transientErrorLookup;

  bool closed;

  Error? loginError;
  //  undefined | AggregateError | ConnectionError;

  DebugOptions debug;

  dynamic ntlmpacket;

  Buffer? ntlmpacketBuffer;

  State STATE = {};

  RoutingData? routingData;

  MessageIO messageIo;

  State state;

  bool? resetConnectionOnNextRequest;

  dynamic request;
  //  undefined | Request | BulkLoad;

  dynamic procReturnStatusValue;

  Socket? socket;

  Buffer messageBuffer;

  Timer? connectTimer;

  Timer? cancelTimer;

  Timer? requestTimer;

  Timer? retryTimer;

  //todo
  void _cancelAfterRequestSent;

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
      } else if (type == 'azure-active-directory-password') {}
    }
  }
}
