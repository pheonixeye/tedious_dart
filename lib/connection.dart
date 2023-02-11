// ignore_for_file: constant_identifier_names, library_private_types_in_public_api, unnecessary_this, unnecessary_null_comparison, unnecessary_type_check

import 'dart:async';
import 'dart:io';

import 'package:events_emitter/events_emitter.dart';
import 'package:node_interop/node_interop.dart';
import 'package:tedious_dart/always_encrypted/keystore_provider_azure_key_vault.dart';
import 'package:tedious_dart/bulk_load.dart';
import 'package:tedious_dart/bulk_load_payload.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/connector.dart';
import 'package:tedious_dart/data_types/int.dart';
import 'package:tedious_dart/data_types/nvarchar.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/instance_lookup.dart';
import 'package:tedious_dart/library.dart';
import 'package:tedious_dart/login7_payload.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/message_io.dart';
import 'package:tedious_dart/metadata_parser.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/random_bytes.dart';
import 'package:tedious_dart/node/abort_controller.dart';
import 'package:tedious_dart/node/connection_m_classes.dart';
import 'package:tedious_dart/ntlm.dart';
import 'package:tedious_dart/ntlm_payload.dart';
import 'package:tedious_dart/packet.dart';
import 'package:tedious_dart/prelogin_payload.dart';
import 'package:tedious_dart/request.dart';
import 'package:tedious_dart/rpcrequest_payload.dart';
import 'package:tedious_dart/sqlbatch_payload.dart';
import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/token/handler.dart';
import 'package:tedious_dart/token/stream_parser.dart';
import 'package:tedious_dart/token/token_stream_parser.dart';
import 'package:tedious_dart/transaction.dart';
import 'package:tedious_dart/transient_error_lookup.dart';

typedef BeginTransactionCallback = void Function(
    {Error? err, Buffer? transactionDescriptor});

typedef SaveTransactionCallback = void Function({Error? err});

typedef CommitTransactionCallback = void Function({Error? err});

typedef RollbackTransactionCallback = void Function({Error? err});

typedef ResetCallback = void Function({Error? err});

typedef TransactionDoneCallback<T> = void Function(
    {Error? err, T done, List<CallbackParameters<T>>? args});

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

//TODO!
/// String? name;
///  void enter({Connection? connection});
///  void exit({Connection? connection, State? newState});
///  void socketError({Connection? connection, Error? err});
///  void connectionTimeout({Connection? connection});
///  void message({Connection? connection, Message? message});
///  void retry({Connection? connection});
///  void reconnect({Connection? connection});
abstract class _State {
  String name;
  Function? enter;
  Function? exit;
  Function? socketError;
  Function? connectionTimeout;
  Function? message;
  Function? retry;
  Function? reconnect;
  _State(
    this.name, {
    this.connectionTimeout,
    this.enter,
    this.exit,
    this.message,
    this.reconnect,
    this.retry,
    this.socketError,
  });
}

class State extends _State {
  static late final Map<String, Function?> eventsMap;
  State(
    super.name, {
    super.connectionTimeout,
    super.enter,
    super.exit,
    super.message,
    super.reconnect,
    super.retry,
    super.socketError,
  }) {
    eventsMap = {
      'enter': this.enter,
      'exit': this.exit,
      'socketError': this.socketError,
      'connectionTimeout': this.connectionTimeout,
      'message': this.message,
      'retry': this.retry,
      'reconnect': this.reconnect,
    };
  }
}

//TODO: ??
// ignore: non_constant_identifier_names
Map<String, State> STATES() {
  final c = Connection(null);
  return {
    "INITIALIZED": State('Initialized'),
    "CONNECTING": State(
      'Connecting',
      enter: () {
        c.initialiseConnection();
      },
      socketError: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
      connectionTimeout: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
    ),
    "SENT_PRELOGIN": State(
      'SentPrelogin',
      enter: () {
        () async {
          var messageBuffer = Buffer.alloc(0);
          late Message message;
          try {
            message = await c.messageIo.readMessage();
          } on Error catch (e, _) {
            return c.socketError(e);
          }

          await for (var data in message) {
            messageBuffer = Buffer.concat([messageBuffer, data]);
          }

          final preloginPayload = PreloginPayload(data: messageBuffer);
          c.debug.payload(() {
            return preloginPayload.toString(indent: '  ');
          });

          if (preloginPayload.fedAuthRequired == 1) {
            c.fedAuthRequired = true;
          }

          if (preloginPayload.encryptionString == 'ON' ||
              preloginPayload.encryptionString == 'REQ') {
            if (!c.config!.options!.encrypt) {
              c.emit(
                  'connect',
                  ConnectionError(
                      "Server requires encryption, set 'encrypt' config option to true.",
                      'EENCRYPT'));
              return c.close();
            }

            try {
              c.transitionTo(c.STATE['SENT_TLSSSLNEGOTIATION']!);
              await c.messageIo.startTls(
                  c.secureContextOptions,
                  c.routingData?.server ?? c.config!.server!,
                  c.routingData?.port as int,
                  c.config!.options!.trustServerCertificate);
            } on Error catch (e) {
              return c.socketError(e);
            }
          }
          c.sendLogin7Packet();

          final authentication = c.config!.authentication!;

          switch (authentication.type) {
            case 'azure-active-directory-password':
            case 'azure-active-directory-msi-vm':
            case 'azure-active-directory-msi-app-service':
            case 'azure-active-directory-service-principal-secret':
            case 'azure-active-directory-default':
              c.transitionTo(c.STATE['SENT_LOGIN7_WITH_FEDAUTH']!);
              break;
            case 'ntlm':
              c.transitionTo(c.STATE['SENT_LOGIN7_WITH_NTLM']!);
              break;
            default:
              c.transitionTo(c.STATE['SENT_LOGIN7_WITH_STANDARD_LOGIN']!);
              break;
          }
        }.call().catchError((e) {
          scheduleMicrotask(() {
            throw e;
          });
        });
      },
      socketError: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
      connectionTimeout: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
    ),
    "REROUTING": State('ReRouting',
        enter: () {
          c.cleanupConnection(CLEANUP_TYPE['REDIRECT']!);
        },
        message: () {},
        socketError: () {
          c.transitionTo(c.STATE['FINAL']!);
        },
        connectionTimeout: () {
          c.transitionTo(c.STATE['FINAL']!);
        },
        reconnect: () {
          c.transitionTo(c.STATE['CONNECTING']!);
        }),
    "TRANSIENT_FAILURE_RETRY": State('TRANSIENT_FAILURE_RETRY',
        enter: () {
          c.curTransientRetryCount++;
          c.cleanupConnection(CLEANUP_TYPE['RETRY']!);
        },
        message: () {},
        socketError: () {
          c.transitionTo(c.STATE['FINAL']!);
        },
        connectionTimeout: () {
          c.transitionTo(c.STATE['FINAL']!);
        },
        retry: () {
          c.createRetryTimer();
        }),
    "SENT_TLSSSLNEGOTIATION": State(
      'SentTLSSSLNegotiation',
      socketError: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
      connectionTimeout: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
    ),
    "SENT_LOGIN7_WITH_STANDARD_LOGIN": State(
      'SentLogin7WithStandardLogin',
      enter: () {
        () async {
          late Message message;
          try {
            message = await c.messageIo.readMessage();
          } on Error catch (e) {
            return c.socketError(e);
          }
          final handler = Login7TokenHandler(c);
          final tokenStreamParser = c.createTokenStreamParser(message, handler);

          await c.once('end', tokenStreamParser);

          if (handler.loginAckReceived) {
            if (handler.routingData != null) {
              c.routingData = handler.routingData;
              c.transitionTo(c.STATE['REROUTING']!);
            } else {
              c.transitionTo(c.STATE['LOGGED_IN_SENDING_INITIAL_SQL']!);
            }
          } else if (c.loginError != null) {
            if (isTransientError(c.loginError)) {
              c.debug.log('Initiating retry on transient error');
              c.transitionTo(c.STATE['TRANSIENT_FAILURE_RETRY']!);
            } else {
              c.emit('connect', c.loginError);
              c.transitionTo(c.STATE['FINAL']!);
            }
          } else {
            c.emit('connect', ConnectionError('Login failed.', 'ELOGIN'));
            c.transitionTo(c.STATE['FINAL']!);
          }
        }.call().catchError((e) {
          scheduleMicrotask(() {
            throw e;
          });
        });
      },
      socketError: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
      connectionTimeout: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
    ),
    "SENT_LOGIN7_WITH_NTLM": State('SentLogin7WithNTLMLogin', enter: () {
      () async {
        while (true) {
          late Message message;
          try {
            message = await c.messageIo.readMessage();
          } on Error catch (e) {
            return c.socketError(e);
          }

          final handler = Login7TokenHandler(c);
          final tokenStreamParser = c.createTokenStreamParser(message, handler);

          await c.once('end', tokenStreamParser);

          if (handler.loginAckReceived) {
            if (handler.routingData != null) {
              c.routingData = handler.routingData;
              return c.transitionTo(c.STATE['REROUTING']!);
            } else {
              return c.transitionTo(c.STATE['LOGGED_IN_SENDING_INITIAL_SQL']!);
            }
          } else if (c.ntlmpacket != null) {
            final authentication =
                c.config!.authentication as NtlmAuthentication;

            final payload = NTLMResponsePayload(
              data: null,
              loginData: NTLMOptions(
                  domain: authentication.options.domain,
                  userName: authentication.options.userName,
                  password: authentication.options.password,
                  ntlmpacket: c.ntlmpacket),
            );

            c.messageIo
                .sendMessage(PACKETTYPE['NTLMAUTH_PKT']!, data: payload.data);
            c.debug.payload(() {
              return payload.toString(indent: '  ');
            });

            c.ntlmpacket = null;
          } else if (c.loginError != null) {
            if (isTransientError(c.loginError)) {
              c.debug.log('Initiating retry on transient error');
              return c.transitionTo(c.STATE['TRANSIENT_FAILURE_RETRY']!);
            } else {
              c.emit('connect', c.loginError);
              return c.transitionTo(c.STATE['FINAL']!);
            }
          } else {
            c.emit('connect', ConnectionError('Login failed.', 'ELOGIN'));
            return c.transitionTo(c.STATE['FINAL']!);
          }
        }
      }.call().catchError((e) {
        scheduleMicrotask(() {
          throw e;
        });
      });
    }, socketError: () {
      c.transitionTo(c.STATE['FINAL']!);
    }, connectionTimeout: () {
      c.transitionTo(c.STATE['FINAL']!);
    }),
    "SENT_LOGIN7_WITH_FEDAUTH": State('SentLogin7Withfedauth', enter: () {
      () async {
        late Message message;
        try {
          message = await c.messageIo.readMessage();
        } on Error catch (e) {
          return c.socketError(e);
        }

        final handler = Login7TokenHandler(c);
        final tokenStreamParser = c.createTokenStreamParser(message, handler);
        await c.once('end', tokenStreamParser);
        if (handler.loginAckReceived) {
          if (handler.routingData != null) {
            c.routingData = handler.routingData;
            c.transitionTo(c.STATE['REROUTING']!);
          } else {
            c.transitionTo(c.STATE['LOGGED_IN_SENDING_INITIAL_SQL']!);
          }

          return;
        }
        final fedAuthInfoToken = handler.fedAuthInfoToken;

        if (fedAuthInfoToken != null &&
            fedAuthInfoToken.stsurl != null &&
            fedAuthInfoToken.spn != null) {
          final authentication = c.config!.authentication;
          final tokenScope =
              Uri(path: '/.default', pathSegments: [fedAuthInfoToken.spn!])
                  .toString();

          dynamic credentials;

          switch (authentication!.type) {
            case 'azure-active-directory-password':
              credentials = UsernamePasswordCredential(
                  authentication.options!.tenantId ?? 'common',
                  authentication.options!.clientId,
                  authentication.options!.userName,
                  authentication.options!.password);
              break;
            case 'azure-active-directory-msi-vm':
            case 'azure-active-directory-msi-app-service':
              final msiArgs = authentication.options!.clientId == null
                  ? [authentication.options!.clientId, {}]
                  : [{}];
              credentials = ManagedIdentityCredential(msiArgs);
              break;
            case 'azure-active-directory-default':
              final args = authentication.options!.clientId == null
                  ? {
                      'managedIdentityClientId':
                          authentication.options!.clientId
                    }
                  : {};
              credentials = DefaultAzureCredential(args);
              break;
            case 'azure-active-directory-service-principal-secret':
              credentials = ClientSecretCredential(
                authentication.options!.clientId!,
                authentication.options!.clientSecret!,
                authentication.options!.tenantId!,
              );
              break;
          }

          dynamic tokenResponse;
          try {
            tokenResponse = await credentials.getToken(tokenScope);
          } catch (err) {
            c.loginError = ConnectionError(
                'Security token could not be authenticated or authorized.',
                'EFEDAUTH');
            c.emit('connect', c.loginError);
            c.transitionTo(c.STATE['FINAL']!);
            return;
          }

          final token = tokenResponse.token;
          c.sendFedAuthTokenMessage(token);
        } else if (c.loginError != null) {
          if (isTransientError(c.loginError)) {
            c.debug.log('Initiating retry on transient error');
            c.transitionTo(c.STATE['TRANSIENT_FAILURE_RETRY']!);
          } else {
            c.emit('connect', c.loginError);
            c.transitionTo(c.STATE['FINAL']!);
          }
        } else {
          c.emit('connect', ConnectionError('Login failed.', 'ELOGIN'));
          c.transitionTo(c.STATE['FINAL']!);
        }
      }.call().catchError((e) {
        scheduleMicrotask(() {
          throw e;
        });
      });
    }, socketError: () {
      c.transitionTo(c.STATE['FINAL']!);
    }, connectionTimeout: () {
      c.transitionTo(c.STATE['FINAL']!);
    }),
    "LOGGED_IN_SENDING_INITIAL_SQL":
        State('LoggedInSendingInitialSql', enter: () {
      () async {
        c.sendInitialSql();
        late Message message;
        try {
          message = await c.messageIo.readMessage();
        } on Error catch (e) {
          return c.socketError(e);
        }
        final tokenStreamParser =
            c.createTokenStreamParser(message, InitialSqlTokenHandler(c));
        await c.once('end', tokenStreamParser);

        c.transitionTo(c.STATE['LOGGED_IN']!);
        c.processedInitialSql();
      }()
          .catchError((e) {
        scheduleMicrotask(() {
          throw e;
        });
      });
    }, socketError: () {
      c.transitionTo(c.STATE['FINAL']!);
    }, connectionTimeout: () {
      c.transitionTo(c.STATE['FINAL']!);
    }),
    "LOGGED_IN": State(
      'LoggedIn',
      socketError: () {
        c.transitionTo(c.STATE['FINAL']!);
      },
    ),
    "SENT_CLIENT_REQUEST": State(
      'SentClientRequest',
      enter: () {
        () async {
          late Message message;
          try {
            message = await c.messageIo.readMessage();
          } on Error catch (e) {
            return c.socketError(e);
          }
          c.clearRequestTimer();

          final tokenStreamParser = c.createTokenStreamParser(
              message,
              RequestTokenHandler(
                c,
                c.request!,
                [],
              ));

          if (c.request?.canceled && c.cancelTimer != null) {
            return c.transitionTo(c.STATE['SENT_ATTENTION']!);
          }
          onResume() {
            tokenStreamParser.resume();
          }

          onPause() {
            tokenStreamParser.pause();

            c.request?.once('resume', onResume);
          }

          c.request?.on('pause', onPause);

          if (c.request is Request && c.request.paused) {
            onPause();
          }

          onEndOfMessage() {
            c.request?.removeListener('cancel', c._cancelAfterRequestSent);
            //ignore:referenced_before_declaration
            c.request?.removeListener('cancel', onCancel);
            c.request?.removeListener('pause', onPause);
            c.request?.removeListener('resume', onResume);

            c.transitionTo(c.STATE['LOGGED_IN']!);
            final sqlRequest = c.request as Request;
            c.request = undefined;
            if (TDSVERSIONS[c.config!.options!.tdsVersion]! <
                    TDSVERSIONS['7_2']! &&
                sqlRequest.error != null &&
                c.isSqlBatch) {
              c.inTransaction = false;
            }
            sqlRequest.callback(
              error: sqlRequest.error,
              rowCount: sqlRequest.rowCount,
              rows: sqlRequest.rows,
            );
          }

          onCancel() {
            tokenStreamParser.removeListener('end', onEndOfMessage);

            if (c.request is Request && c.request.paused) {
              // resume the request if it was paused so we can read the remaining tokens
              c.request.resume();
            }

            c.request?.removeListener('pause', onPause);
            c.request?.removeListener('resume', onResume);

            // The `_cancelAfterRequestSent` callback will have sent a
            // attention message, so now we need to also switch to
            // the `SENT_ATTENTION` state to make sure the attention ack
            // message is processed correctly.
            c.transitionTo(c.STATE['SENT_ATTENTION']!);
          }

          tokenStreamParser.once('end', onEndOfMessage);
          c.request?.once('cancel', onCancel);
        }.call();
      },
      exit: (State nextState) {
        c.clearRequestTimer();
      },
      socketError: (err) {
        final sqlRequest = c.request!;
        c.request = null;
        c.transitionTo(c.STATE['FINAL']!);

        sqlRequest.callback(err);
      },
    ),
    "SENT_ATTENTION": State('SentAttention', enter: () {
      () async {
        late Message message;
        try {
          message = await c.messageIo.readMessage();
        } on Error catch (e) {
          return c.socketError(e);
        }

        final handler = AttentionTokenHandler(c, c.request!);
        final tokenStreamParser = c.createTokenStreamParser(message, handler);

        await c.once('end', tokenStreamParser);
        // 3.2.5.7 Sent Attention State
        // Discard any data contained in the response, until we receive the attention response
        if (handler.attentionReceived) {
          c.clearCancelTimer();

          final sqlRequest = c.request! as Request;
          c.request = null;
          c.transitionTo(c.STATE['LOGGED_IN']!);

          if (sqlRequest.error != null &&
              sqlRequest.error is RequestError &&
              sqlRequest.error!.code == 'ETIMEOUT') {
            sqlRequest.callback(error: sqlRequest.error);
          } else {
            sqlRequest.callback(
                error: RequestError(message: 'Canceled.', code: 'ECANCEL'));
          }
        }
      }()
          .catchError((e) {
        scheduleMicrotask(() {
          throw e;
        });
      });
    }, socketError: (err) {
      final sqlRequest = c.request!;
      c.request = null;

      c.transitionTo(c.STATE['FINAL']!);

      sqlRequest.callback(err);
    }),
    "FINAL": State('Final', enter: () {
      c.cleanupConnection(CLEANUP_TYPE['NORMAL']!);
    }, connectionTimeout: () {
      // Do nothing, as the timer should be cleaned up.
    }, message: () {
      // Do nothing
    }, socketError: () {
      // Do nothing
    }),
  };
}

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

class InternalConnectionConfig {
  String? server;
  InternalConnectionOptions? options;
  _Authentication? authentication;

  InternalConnectionConfig({
    required this.server,
    required this.options,
    required this.authentication,
  });
}

class ConnectionConfiguration {
  String server;
  ConnectionOptions options;
  AuthenticationOptions authentication;

  ConnectionConfiguration({
    required this.server,
    required this.options,
    required this.authentication,
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
  Map<String, State> STATE = STATES();

  RoutingData? routingData;

  late MessageIO messageIo;

  late State? state;

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

    this.state = this.STATE['INITIALIZED']!;

    this._cancelAfterRequestSent = (_) {
      this.messageIo.sendMessage(PACKETTYPE['ATTENTION']!);
      this.createCancelTimer();
    };
    //TODO! end of constructor
  }

  connect(void Function(Error error)? connectListener) {
    if (this.state != this.STATE['INITIALIZED']!) {
      throw ConnectionError(
          '`.connect` can not be called on a Connection in `${this.state!.name}` state.');
    }

    if (connectListener != null) {
      onError(Error err) {
        this.removeEventListener(EventListener('connect', (error) {}));
        connectListener(err);
      }

      onConnect(Error err) {
        this.removeEventListener(EventListener('error', onError));
        connectListener(err);
      }

      this.once('connect', onConnect);
      this.once('error', onError);
    }

    this.transitionTo(this.STATE['CONNECTING']!);
  }

  close() {
    this.transitionTo(this.STATE['FINAL']!);
  }

  initialiseConnection() {
    final signal = this.createConnectTimer();

    if (this.config!.options!.port != null) {
      return this.connectOnPort(
        this.config!.options!.port!,
        this.config!.options!.multiSubnetFailover,
        signal,
      );
    } else {
      return instanceLookup(InstanceLookUpOptions(
        server: this.config!.server,
        instanceName: this.config!.options!.instanceName!,
        timeout: this.config!.options!.connectTimeout,
        signal: signal,
      )).then((port) {
        scheduleMicrotask(() {
          this.connectOnPort(
            port,
            this.config!.options!.multiSubnetFailover,
            signal,
          );
        });
      }).catchError((err) {
        this.clearConnectTimer();
        if (err.name == 'AbortError') {
          // Ignore the AbortError for now, this is still handled by the connectTimer firing
          return;
        }
        scheduleMicrotask(() {
          this.emit('connect', ConnectionError(err.message, 'EINSTLOOKUP'));
        });
      });
    }
  }

  cleanupConnection(int cleanupType) {
    if (!this.closed) {
      this.clearConnectTimer();
      this.clearRequestTimer();
      this.clearRetryTimer();
      this.closeConnection();
      if (cleanupType == CLEANUP_TYPE['REDIRECT']) {
        this.emit('rerouting');
      } else if (cleanupType != CLEANUP_TYPE['RETRY']) {
        scheduleMicrotask(() {
          this.emit('end');
        });
      }

      final request = this.request;
      if (request) {
        final err = RequestError(
            message: 'Connection closed before request completed.',
            code: 'ECLOSE');
        request.callback(err);
        this.request = undefined;
      }

      this.closed = true;
      this.loginError = undefined;
    }
  }

  createDebug() {
    final debug = Debug(options: this.config!.options!.debug!);
    debug.on('debug', (message) {
      this.emit('debug', message);
    });
    return debug;
  }

  createTokenStreamParser(Message message, TokenHandler handler) {
    return TokenStreamParser(
      //TODO:
      message: message,
      debug: this.debug,
      tokenHandler: handler,
      options: ParserOptions(
        camelCaseColumns: this.config!.options!.camelCaseColumns,
        columnNameReplacer: this.config!.options!.columnNameReplacer,
        lowerCaseGuids: this.config!.options!.lowerCaseGuids,
        tdsVersion: this.config!.options!.tdsVersion,
        useColumnNames: this.config!.options!.useColumnNames,
        useUTC: this.config!.options!.useUTC,
      ),
    );
  }

  connectOnPort(num port, bool multiSubnetFailover, AbortSignal signal) {
    //TODO:
    final connectOpts = {
      'host': this.routingData != null
          ? this.routingData!.server
          : this.config!.server,
      'port': this.routingData != null ? this.routingData!.port : port,
      'localAddress': this.config!.options!.localAddress,
    };

    final connect = multiSubnetFailover ? connectInParallel : connectInSequence;
    connect(connectOpts, signal).then((socket) {
      scheduleMicrotask(() async {
        final sub = socket.listen((event) {});
        sub.onDone(() {
          socketEnd();
        });
        sub.onError((error) {
          socketError(error);
        });
        if (await socket.done == true) {
          socketClose();
        }
        //
        this.messageIo = MessageIO(
          socket,
          this.config!.options!.packetSize as int,
          this.debug,
        );
        this
            .messageIo
            .on('secure', (cleartext) => {this.emit('secure', cleartext)});

        this.socket = socket;
        this.closed = false;
        this.debug.log(
            'connected to ${this.config!.server!}:${this.config!.options!.port}');

        this.sendPreLogin();
        this.transitionTo(this.STATE['SENT_PRELOGIN']!);
      });
      //TODO!!!!!!: socket.on('event', (){});
    });
  }

  closeConnection() {
    if (this.socket != null) {
      this.socket!.destroy();
    }
  }

  createConnectTimer() {
    final controller = AbortController();
    this.connectTimer = Timer(
      Duration(
        seconds: this.config!.options!.connectTimeout as int,
      ),
      () {
        controller.abort();
        this.connectTimeout();
      },
    );
    return controller.signal;
  }

  createCancelTimer() {
    this.clearCancelTimer();
    final timeout = this.config!.options!.cancelTimeout;
    if (timeout > 0) {
      this.cancelTimer = Timer(
        Duration(seconds: timeout as int),
        () {
          this.cancelTimeout();
        },
      );
    }
  }

  createRequestTimer() {
    this.clearRequestTimer(); // release old timer, just to be safe
    final request = this.request as Request;
    final timeout = (request.timeout != null)
        ? request.timeout
        : this.config!.options!.requestTimeout;
    if (timeout != null) {
      // this.requestTimer = setTimeout(() => {
      //   this.requestTimeout();
      // }, timeout);
      this.requestTimer = Timer(
        Duration(seconds: timeout as int),
        () {
          this.requestTimeout();
        },
      );
    }
  }

  createRetryTimer() {
    this.clearRetryTimer();
    this.retryTimer = Timer(
      Duration(seconds: this.config!.options!.connectionRetryInterval as int),
      () {
        this.retryTimeout();
      },
    );
    // this.retryTimer = setTimeout(
    //   () {
    //     this.retryTimeout();
    //   },
    //   this.config!.options!.connectionRetryInterval,
    // );
  }

  connectTimeout() {
    final message = """ 
    Failed to connect to ${this.config!.server} ${this.config!.options!.port == null ? this.config!.options!.port : this.config!.options!.instanceName} in ${this.config!.options!.connectTimeout} ms
    """;
    this.debug.log(message);
    this.emit('connect', ConnectionError(message, 'ETIMEOUT'));
    this.connectTimer = undefined;
    this.dispatchEvent('connectTimeout');
  }

  cancelTimeout() {
    final message =
        'Failed to cancel request in ${this.config!.options!.cancelTimeout}ms';
    this.debug.log(message);
    this.dispatchEvent('socketError', ConnectionError(message, 'ETIMEOUT'));
  }

  requestTimeout() {
    this.requestTimer = null;
    final request = this.request!;
    request.cancel();
    final timeout = (request.timeout != null)
        ? request.timeout
        : this.config!.options!.requestTimeout;
    final message = 'Timeout: Request failed to complete in $timeout ms';
    request.error = RequestError(message: message, code: 'ETIMEOUT');
  }

  retryTimeout() {
    this.retryTimer = undefined;
    this.emit('retry');
    this.transitionTo(this.STATE['CONNECTING']!);
  }

  clearConnectTimer() {
    if (this.connectTimer != null) {
      this.connectTimer!.cancel();
      // clearTimeout(this.connectTimer);
      this.connectTimer = undefined;
    }
  }

  clearCancelTimer() {
    if (this.cancelTimer != null) {
      this.cancelTimer!.cancel();
      // clearTimeout(this.cancelTimer);
      this.cancelTimer = undefined;
    }
  }

  clearRequestTimer() {
    if (this.requestTimer != null) {
      this.requestTimer!.cancel();
      // clearTimeout(this.requestTimer);
      this.requestTimer = undefined;
    }
  }

  clearRetryTimer() {
    if (this.retryTimer != null) {
      this.retryTimer!.cancel();
      // clearTimeout(this.retryTimer);
      this.retryTimer = undefined;
    }
  }

  transitionTo(State newState) {
    if (this.state == newState) {
      this.debug.log('State is already ${newState.name}');
      return;
    }

    if (this.state != null && this.state!.exit != null) {
      this.state!.exit!(this, newState);
    }

    this.debug.log(
        'State change: ${this.state != null ? this.state!.name : 'undefined'} -> ${newState.name}');
    this.state = newState;

    if (this.state!.enter != null) {
      Function.apply(this.state!.enter!, [this]);
    }
  }

  getEventHandler(String eventName) {
    final handler = State.eventsMap[eventName];
    if (handler == null) {
      throw MTypeError("No event '$eventName' in state '${this.state!.name}'");
    }
    return handler!;
  }

  dispatchEvent(String eventName, [dynamic args]) {
    final handler = State.eventsMap[eventName] as void Function(
        Connection? connection, dynamic args)?;
    if (handler != null) {
      Function.apply(handler, [this, args]);
      // handler(this, args);
    } else {
      this.emit('error',
          MTypeError("No event '$eventName' in state '${this.state!.name}"));
      this.close();
    }
  }

  socketError(Error error) {
    if (this.state == this.STATE['CONNECTING'] ||
        this.state == this.STATE['SENT_TLSSSLNEGOTIATION']) {
      final message =
          'Failed to connect to ${this.config!.server}:${this.config!.options!.port} - ${error.toString()}';
      this.debug.log(message);
      this.emit('connect', ConnectionError(message, 'ESOCKET'));
    } else {
      final message = 'Connection lost - ${error.toString()}';
      this.debug.log(message);
      this.emit('error', ConnectionError(message, 'ESOCKET'));
    }
    this.dispatchEvent('socketError', error);
  }

  socketEnd() {
    this.debug.log('socket ended');
    if (this.state != this.STATE['FINAL']) {
      final error = ConnectionError('socket hang up');
      error.code = 'ECONNRESET';
      this.socketError(error);
    }
  }

  socketClose() {
    this.debug.log(
        'connection to ${this.config!.server!}:${this.config!.options!.port} closed');
    if (this.state == this.STATE['REROUTING']) {
      this.debug.log(
          'Rerouting to ${this.routingData!.server}:${this.routingData!.port}');

      this.dispatchEvent('reconnect');
    } else if (this.state == this.STATE['TRANSIENT_FAILURE_RETRY']) {
      final server = this.routingData != null
          ? this.routingData!.server
          : this.config!.server;
      final port = this.routingData != null
          ? this.routingData!.port
          : this.config!.options!.port;
      this
          .debug
          .log('Retry after transient failure connecting to ${server!}:$port');

      this.dispatchEvent('retry');
    } else {
      this.transitionTo(this.STATE['FINAL']!);
    }
  }

  sendPreLogin() {
    // final [, major, minor, build] = /^(\d+)\.(\d+)\.(\d+)/.exec(version) ?? ['0.0.0', '0', '0', '0'];
    final major = '0.0.0';
    final minor = '0';
    final build = '0';
    final subbuild = '0';
    final payload = PreloginPayload(
      options: PreloginPayloadOptions(
        encrypt: this.config!.options!.encrypt,
        version: PreloginPayloadVersion(
          major: num.parse(major),
          minor: num.parse(minor),
          build: num.parse(build),
          subbuild: num.parse(subbuild),
        ),
      ),
    );

    this.messageIo.sendMessage(PACKETTYPE['PRELOGIN']!, data: payload.data);
    this.debug.payload(() {
      return payload.toString(indent: '  ');
    });
  }

  sendLogin7Packet() {
    final payload = Login7Payload(
      login7Options: Login7Options(
          tdsVersion: TDSVERSIONS[this.config!.options!.tdsVersion],
          packetSize: this.config!.options!.packetSize,
          clientProgVer: 0,
          clientPid: process.pid,
          connectionId: 0,
          clientTimeZone: DateTime.now().timeZoneOffset.inMinutes,
          clientLcid: 0x00000409),
    );

    var authentication = this.config!.authentication!;
    switch (authentication.type) {
      case 'azure-active-directory-password':
        payload.fedAuth = FedAuth(
            type: 'ADAL', echo: this.fedAuthRequired, workflow: 'default');
        break;

      case 'azure-active-directory-access-token':
        payload.fedAuth = FedAuth(
            type: 'SECURITYTOKEN',
            echo: this.fedAuthRequired,
            fedAuthToken: authentication.options!.token);
        break;

      case 'azure-active-directory-msi-vm':
      case 'azure-active-directory-default':
      case 'azure-active-directory-msi-app-service':
      case 'azure-active-directory-service-principal-secret':
        payload.fedAuth = FedAuth(
            type: 'ADAL', echo: this.fedAuthRequired, workflow: 'integrated');
        break;

      case 'ntlm':
        payload.sspi = createNTLMRequest(
          NTLMrequestOption(
            domain: authentication.options!.domain,
          ),
        );
        break;

      default:
        payload.userName = authentication.options!.userName;
        payload.password = authentication.options!.password;
    }

    payload.hostname =
        this.config!.options!.workstationId ?? Platform.localHostname;
    payload.serverName = this.routingData == null
        ? this.routingData!.server
        : this.config!.server;
    payload.appName = this.config!.options!.appName ?? 'Tedious';
    payload.libraryName = LIBRARYNAME;
    payload.language = this.config!.options!.language;
    payload.database = this.config!.options!.database;
    payload.clientId = Buffer.from([1, 2, 3, 4, 5, 6]);

    payload.readOnlyIntent = this.config!.options!.readOnlyIntent;
    payload.initDbFatal = !this.config!.options!.fallbackToDefaultDb;

    this.routingData = undefined;
    this.messageIo.sendMessage(PACKETTYPE['LOGIN7']!, data: payload.toBuffer());

    this.debug.payload(() {
      return payload.toString(indent: '  ');
    });
  }

  sendFedAuthTokenMessage(String token) {
    final accessTokenLen = Buffer.byteLength(token, 'ucs2');
    final data = Buffer.alloc(8 + accessTokenLen.length);
    var offset = 0;
    offset = data.writeUInt32LE(accessTokenLen.length + 4, offset);
    offset = data.writeUInt32LE(accessTokenLen.length, offset);
    data.write(token, offset, 0, 'ucs2');
    this.messageIo.sendMessage(PACKETTYPE['FEDAUTH_TOKEN']!, data: data);
    // sent the fedAuth token message, the rest is similar to standard login 7
    //TODO:
    this.transitionTo(this.STATE['SENT_LOGIN7_WITH_STANDARD_LOGIN']!);
  }

  sendInitialSql() async {
    final payload = SqlBatchPayload(
      sqlText: this.getInitialSql(),
      txnDescriptor: this.currentTransactionDescriptor(),
      tdsVersion: this.config!.options!.tdsVersion,
    );

    final message = Message(
      type: PACKETTYPE['SQL_BATCH']!,
      resetConnection: false,
    );
    this
        .messageIo
        .outgoingMessageStream!
        .write(message, 'usc-2', (([error]) {}));
    //TODO* Readable.from(payload).pipe(message);
    final _controller = StreamController.broadcast();
    _controller.addStream(payload);
    _controller.add(message);
  }

  getInitialSql() {
    List options = [];

    if (this.config!.options!.enableAnsiNull == true) {
      options.add('set ansi_nulls on');
    } else if (this.config!.options!.enableAnsiNull == false) {
      options.add('set ansi_nulls off');
    }

    if (this.config!.options!.enableAnsiNullDefault == true) {
      options.add('set ansi_null_dflt_on on');
    } else if (this.config!.options!.enableAnsiNullDefault == false) {
      options.add('set ansi_null_dflt_on off');
    }

    if (this.config!.options!.enableAnsiPadding == true) {
      options.add('set ansi_padding on');
    } else if (this.config!.options!.enableAnsiPadding == false) {
      options.add('set ansi_padding off');
    }

    if (this.config!.options!.enableAnsiWarnings == true) {
      options.add('set ansi_warnings on');
    } else if (this.config!.options!.enableAnsiWarnings == false) {
      options.add('set ansi_warnings off');
    }

    if (this.config!.options!.enableArithAbort == true) {
      options.add('set arithabort on');
    } else if (this.config!.options!.enableArithAbort == false) {
      options.add('set arithabort off');
    }

    if (this.config!.options!.enableConcatNullYieldsNull == true) {
      options.add('set concat_null_yields_null on');
    } else if (this.config!.options!.enableConcatNullYieldsNull == false) {
      options.add('set concat_null_yields_null off');
    }

    if (this.config!.options!.enableCursorCloseOnCommit == true) {
      options.add('set cursor_close_on_commit on');
    } else if (this.config!.options!.enableCursorCloseOnCommit == false) {
      options.add('set cursor_close_on_commit off');
    }

    if (this.config!.options!.datefirst != null) {
      options.add('set datefirst ${this.config!.options!.datefirst}');
    }

    if (this.config!.options!.dateFormat != null) {
      options.add('set dateformat ${this.config!.options!.dateFormat}');
    }

    if (this.config!.options!.enableImplicitTransactions == true) {
      options.add('set implicit_transactions on');
    } else if (this.config!.options!.enableImplicitTransactions == false) {
      options.add('set implicit_transactions off');
    }

    if (this.config!.options!.language != null) {
      options.add('set language ${this.config!.options!.language}');
    }

    if (this.config!.options!.enableNumericRoundabort == true) {
      options.add('set numeric_roundabort on');
    } else if (this.config!.options!.enableNumericRoundabort == false) {
      options.add('set numeric_roundabort off');
    }

    if (this.config!.options!.enableQuotedIdentifier == true) {
      options.add('set quoted_identifier on');
    } else if (this.config!.options!.enableQuotedIdentifier == false) {
      options.add('set quoted_identifier off');
    }

    if (this.config!.options!.textsize != null) {
      options.add('set textsize ${this.config!.options!.textsize}');
    }

    if (this.config!.options!.connectionIsolationLevel != null) {
      options.add(
          'set transaction isolation level ${this.getIsolationLevelText(this.config!.options!.connectionIsolationLevel)}');
    }

    if (this.config!.options!.abortTransactionOnError == true) {
      options.add('set xact_abort on');
    } else if (this.config!.options!.abortTransactionOnError == false) {
      options.add('set xact_abort off');
    }

    return options.join('\n');
  }

  processedInitialSql() {
    this.clearConnectTimer();
    this.emit('connect');
  }

  execSqlBatch(Request request) {
    this.makeRequest(
        request,
        PACKETTYPE['SQL_BATCH']!,
        SqlBatchPayload(
          sqlText: request.sqlTextOrProcedure!,
          txnDescriptor: this.currentTransactionDescriptor(),
          tdsVersion: this.config!.options!.tdsVersion,
        ));
  }

  execSql(Request request) {
    try {
      request.validateParameters(this.databaseCollation);
    } catch (error) {
      request.error = RequestError(message: error.toString());

      scheduleMicrotask(() {
        this.debug.log(error.toString());
        request.callback(error: MTypeError(error.toString()));
      });

      return;
    }

    List<Parameter> parameters = [];

    parameters.add(Parameter(
        type: DATATYPES[NVarChar.refID],
        name: 'statement',
        value: request.sqlTextOrProcedure,
        output: false,
        length: null,
        precision: null,
        scale: null));

    if (request.parameters.isNotEmpty) {
      parameters.add(Parameter(
          type: DATATYPES[NVarChar.refID],
          name: 'params',
          value: request.makeParamsParameter(request.parameters),
          output: false,
          length: null,
          precision: null,
          scale: null));

      parameters.addAll(request.parameters);
    }

    this.makeRequest(
        request,
        PACKETTYPE['RPC_REQUEST']!,
        RpcRequestPayload(
          procedure: 'sp_executesql',
          parameters: parameters,
          txnDescriptor: this.currentTransactionDescriptor(),
          options: this.config!.options!,
          collation: this.databaseCollation,
        ));
  }

  newBulkLoad(
      String table, dynamic callbackOrOptions, BulkLoadCallback? callback) {
    //callbackOrOptions = BulkLoadOptions | BulkLoadCallback
    late BulkLoadOptions options;

    if (callback == null) {
      callback = callbackOrOptions as BulkLoadCallback;
      options = BulkLoadOptions();
    } else {
      options = callbackOrOptions as BulkLoadOptions;
    }

    if (options is! BulkLoadOptions) {
      throw MTypeError('"options" argument must be an object');
    }
    return BulkLoad(
      table: table,
      collation: this.databaseCollation,
      options: this.config!.options!,
      bulkOptions: options.options!,
      callback: callback,
    );
  }

  //* something wrong or i am a genius xD
  execBulkLoad(BulkLoad bulkLoad, dynamic rows) {
    //* rows = AsyncIterable<unknown[] | { [columnName: string]: unknown }> | Iterable<unknown[] | { [columnName: string]: unknown }>
    bulkLoad.executionStarted = true;

    if (rows != null) {
      if (bulkLoad.streamingMode) {
        throw MTypeError(
            "Connection.execBulkLoad can't be called with a BulkLoad that was put in streaming mode.");
      }

      if (bulkLoad.firstRowWritten) {
        throw MTypeError(
            "Connection.execBulkLoad can't be called with a BulkLoad that already has rows written to it.");
      }

      //TODO!: Stream.fromIterable(rows) = Readable.from(rows);
      final _rowStream = Stream.fromIterable(rows).asBroadcastStream();
      final rowStreamController = StreamController();
      rowStreamController.addStream(_rowStream);
      final rowStreamSubscription =
          rowStreamController.stream.listen((event) {});

      // Destroy the packet transform if an error happens in the row stream,
      // e.g. if an error is thrown from within a generator or stream.
      rowStreamSubscription.onError((err) {
        //* bulkLoad.rowToPacketTransform.destroy(err);
        bulkLoad.rowToPacketTransform.controller.close();
      });

      // Destroy the row stream if an error happens in the packet transform,
      // e.g. if the bulk load is cancelled.
      bulkLoad.rowToPacketTransform.controller.stream.handleError((err) {
        rowStreamController.addError(err);
        rowStreamController.close();
      });
      //* rowStream.pipe(bulkLoad.rowToPacketTransform);

      // rowStreamController.add(bulkLoad.rowToPacketTransform);

      bulkLoad.rowToPacketTransform.controller
          .addStream(rowStreamController.stream);
      //TODO??: maybe??
      //
    } else if (!bulkLoad.streamingMode) {
      // If the bulkload was not put into streaming mode by the user,
      // we end the rowToPacketTransform here for them.
      //
      // If it was put into streaming mode, it's the user's responsibility
      // to end the stream.
      bulkLoad.rowToPacketTransform.controller.close();
    }

    late final Request request;

    onCancel() {
      request.cancel();
    }

    final payload = BulkLoadPayload(bulkLoad: bulkLoad);

    request = Request(
        sqlTextOrProcedure: bulkLoad.getBulkInsertSql(),
        callback: ({error, rowCount, rows}) {
          bulkLoad.once('cancel', (_) {
            onCancel();
          });

          if (error != null) {
            if (error.toString() == 'UNKNOWN') {
              error = MTypeError(
                  ' This is likely because the schema of the BulkLoad does not match the schema of the table you are attempting to insert into.');
            }
            bulkLoad.error = error;
            bulkLoad.callback(error, 0);
            return;
          }

          this.makeRequest(bulkLoad, PACKETTYPE['BULK_LOAD']!, payload);
        });

    bulkLoad.once('cancel', (_) {
      onCancel();
    });

    this.execSqlBatch(request);
  }

  prepare(Request request) {
    List<Parameter> parameters = [];

    parameters.add(Parameter(
      type: DATATYPES[Int.refID],
      name: 'handle',
      value: null,
      output: true,
      length: null,
      precision: null,
      scale: null,
    ));

    parameters.add(Parameter(
      type: DATATYPES[NVarChar.refID],
      name: 'params',
      value: request.parameters.isEmpty
          ? request.makeParamsParameter(request.parameters)
          : null,
      output: false,
      length: null,
      precision: null,
      scale: null,
    ));

    parameters.add(Parameter(
      type: DATATYPES[NVarChar.refID],
      name: 'stmt',
      value: request.sqlTextOrProcedure,
      output: false,
      length: null,
      precision: null,
      scale: null,
    ));

    request.preparing = true;
    // TODO: We need to clean up this event handler, otherwise this leaks memory
    // TODO: original function signature was with 2 parameters (String name, dynamic value);
    request.on('returnValue', (Map<String, dynamic> returnValue) {
      if (returnValue['name'] == 'handle') {
        request.handle = returnValue['value']!;
      } else {
        request.error = RequestError(
          code: 'Unexpected output parameter',
          message:
              'Tedious > Unexpected output parameter ${returnValue['name']} from sp_prepare',
        );
      }
    });

    this.makeRequest(
      request,
      PACKETTYPE['RPC_REQUEST']!,
      RpcRequestPayload(
        procedure: 'sp_prepare',
        parameters: parameters,
        txnDescriptor: this.currentTransactionDescriptor(),
        options: this.config!.options!,
        collation: this.databaseCollation,
      ),
    );
  }

  unprepare(Request request) {
    List<Parameter> parameters = [];

    parameters.add(Parameter(
        type: DATATYPES[Int.refID],
        name: 'handle',
        // TODO: Abort if 'request.handle' is not set
        value: request.handle,
        output: false,
        length: null,
        precision: null,
        scale: null));

    this.makeRequest(
      request,
      PACKETTYPE['RPC_REQUEST']!,
      RpcRequestPayload(
        procedure: 'sp_unprepare',
        parameters: parameters,
        txnDescriptor: this.currentTransactionDescriptor(),
        options: this.config!.options!,
        collation: this.databaseCollation,
      ),
    );
  }

  execute(Request request, Map<String, dynamic>? parameters) {
    List<Parameter> executeParameters = [];

    executeParameters.add(Parameter(
        type: DATATYPES[Int.refID],
        name: 'handle',
        // TODO: Abort if 'request.handle' is not set
        value: request.handle,
        output: false,
        length: null,
        precision: null,
        scale: null));

    try {
      for (int i = 0, len = request.parameters.length; i < len; i++) {
        var parameter = request.parameters[i];

        executeParameters.add(parameter
          ..value = parameter.type!.validate(
              parameters != null ? parameters[parameter.name] : null,
              this.databaseCollation));
      }
    } catch (error) {
      request.error = RequestError(message: error.toString());

      process.nextTick(() {
        this.debug.log(error.toString());
        request.callback(error: MTypeError(error.toString()));
      });

      return;
    }

    this.makeRequest(
        request,
        PACKETTYPE['RPC_REQUEST']!,
        RpcRequestPayload(
          procedure: 'sp_execute',
          parameters: executeParameters,
          txnDescriptor: this.currentTransactionDescriptor(),
          options: this.config!.options!,
          collation: this.databaseCollation,
        ));
  }

  callProcedure(Request request) {
    try {
      request.validateParameters(this.databaseCollation);
    } catch (error) {
      request.error = RequestError(message: error.toString());

      process.nextTick(() {
        this.debug.log(error.toString());
        request.callback(
          error: MTypeError(error.toString()),
        );
      });

      return;
    }

    this.makeRequest(
        request,
        PACKETTYPE['RPC_REQUEST']!,
        RpcRequestPayload(
            procedure: request.sqlTextOrProcedure!,
            parameters: request.parameters,
            txnDescriptor: this.currentTransactionDescriptor(),
            options: this.config!.options!,
            collation: this.databaseCollation));
  }

  beginTransaction(
      {required BeginTransactionCallback callback,
      String name = '',
      num? isolationLevel}) {
    isolationLevel = this.config!.options!.isolationLevel;
    assertValidIsolationLevel(isolationLevel, 'isolationLevel');

    final transaction = Transaction(name: name, isolationLevel: isolationLevel);

    if (TDSVERSIONS[this.config!.options!.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return this.execSqlBatch(Request(
          sqlTextOrProcedure:
              'SET TRANSACTION ISOLATION LEVEL ${transaction.isolationLevelToTSQL()};BEGIN TRAN ${transaction.name}',
          callback: ({error, rowCount, rows}) {
            this.transactionDepth++;
            if (this.transactionDepth == 1) {
              this.inTransaction = true;
            }
            callback(err: error);
          }));
    }

    final request = Request(
        sqlTextOrProcedure: null,
        callback: ({error, rowCount, rows}) {
          return callback(
            err: error,
            transactionDescriptor: this.currentTransactionDescriptor(),
          );
        });
    return this.makeRequest(request, PACKETTYPE['TRANSACTION_MANAGER']!,
        transaction.beginPayload(this.currentTransactionDescriptor()));
  }

  commitTransaction({
    required CommitTransactionCallback callback,
    String name = '',
  }) {
    final transaction = Transaction(name: name);
    if (TDSVERSIONS[this.config!.options!.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return this.execSqlBatch(Request(
          sqlTextOrProcedure: 'COMMIT TRAN ${transaction.name}',
          callback: ({error, rowCount, rows}) {
            this.transactionDepth--;
            if (this.transactionDepth == 0) {
              this.inTransaction = false;
            }

            callback(err: error);
          }));
    }

    //TODO
    //ignore:argument_type_not_assignable
    final request = Request(sqlTextOrProcedure: '', callback: callback);
    return this.makeRequest(request, PACKETTYPE['TRANSACTION_MANAGER']!,
        transaction.commitPayload(this.currentTransactionDescriptor()));
  }

  rollbackTransaction({
    required RollbackTransactionCallback callback,
    String name = '',
  }) {
    var transaction = Transaction(name: name);
    if (TDSVERSIONS[this.config!.options!.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return this.execSqlBatch(
        Request(
          sqlTextOrProcedure: 'ROLLBACK TRAN ${transaction.name}',
          callback: ({error, rowCount, rows}) {
            this.transactionDepth--;
            if (this.transactionDepth == 0) {
              this.inTransaction = false;
            }
            callback(err: error);
          },
        ),
      );
    }

    //TODO
    //ignore:argument_type_not_assignable
    var request = Request(sqlTextOrProcedure: '', callback: callback);
    return this.makeRequest(request, PACKETTYPE['TRANSACTION_MANAGER']!,
        transaction.rollbackPayload(this.currentTransactionDescriptor()));
  }

  saveTransaction(SaveTransactionCallback? callback, String name) {
    var transaction = Transaction(name: name);
    if (TDSVERSIONS[this.config!.options!.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return this.execSqlBatch(
        Request(
          sqlTextOrProcedure: 'SAVE TRAN ${transaction.name}',
          callback: ({error, rowCount, rows}) {
            this.transactionDepth++;
            callback!(err: error);
          },
        ),
      );
    }
    //TODO
    //ignore:argument_type_not_assignable
    var request = Request(sqlTextOrProcedure: null, callback: callback);
    return this.makeRequest(
      request,
      PACKETTYPE['TRANSACTION_MANAGER']!,
      transaction.savePayload(this.currentTransactionDescriptor()),
    );
  }

  transaction(
    void Function({
      Error? error,
      TransactionDoneCallback? txDone,
      List<CallbackParameters>? args,
    })?
        cb,
    num? isolationLevel,
  ) {
    if (cb is! Function) {
      throw MTypeError('cb must be a function');
    }

    var useSavepoint = this.inTransaction;

    var name = '_tedious_${(RandomBytes.gen(10, isString: true))}';

    //function def inside a fns
    void txDone({
      Error? err,
      TransactionDoneCallback? done,
      List<CallbackParameters>? args,
    }) {
      if (err != null) {
        if (this.inTransaction && this.state == this.STATE['LOGGED_IN']) {
          this.rollbackTransaction(
            callback: ({err}) {
              done!(err: err, args: args);
            },
            name: name,
          );
        } else {
          done!(err: err, args: args);
        }
      } else if (useSavepoint) {
        if (TDSVERSIONS[this.config!.options!.tdsVersion]! <
            TDSVERSIONS['7_2']!) {
          this.transactionDepth--;
        }
        done!(err: null, args: args);
      } else {
        this.commitTransaction(
          callback: ({err}) {
            done!(err: err, args: args);
          },
          name: name,
        );
      }
    }
    //end of fns declaration

    if (useSavepoint) {
      return this.saveTransaction(({err}) {
        if (err != null) {
          return cb!(error: err);
        }

        if (isolationLevel != null) {
          execSqlBatch(
            Request(
              sqlTextOrProcedure:
                  'SET transaction isolation level ${this.getIsolationLevelText(isolationLevel)}',
              callback: ({error, rowCount, rows}) {
                //TODO
                //ignore:argument_type_not_assignable
                return cb!(error: err, txDone: txDone);
              },
            ),
          );
        } else {
          //TODO
          //ignore:argument_type_not_assignable
          return cb!(error: null, txDone: txDone);
        }
      }, name);
    } else {
      return this.beginTransaction(
          callback: ({err, transactionDescriptor}) {
            if (err != null) {
              return cb!(error: err);
            }

            //TODO
            //ignore:argument_type_not_assignable
            return cb!(error: null, txDone: txDone);
          },
          name: name,
          isolationLevel: isolationLevel);
    }
  }

  //TODO: check & double check for better implementation
  makeRequest(dynamic request, num packetType, Stream<Buffer> payload,
      {String Function(String indent)? toString}) {
    //*request = Request || BulkLoad
    if (this.state != this.STATE['LOGGED_IN']) {
      var message =
          'Requests can only be made in the ${this.STATE['LOGGED_IN']!.name} state, not the ${this.state?.name} state';
      this.debug.log(message);
      request.callback(
          error: RequestError(message: message, code: 'EINVALIDSTATE'));
    } else if (request.canceled) {
      scheduleMicrotask(() {
        request.callback(
            error: RequestError(message: 'Canceled.', code: 'ECANCEL'));
      });
    } else {
      if (packetType == PACKETTYPE['SQL_BATCH']) {
        this.isSqlBatch = true;
      } else {
        this.isSqlBatch = false;
      }

      var message = Message(
        type: packetType as int,
        resetConnection: this.resetConnectionOnNextRequest!,
      );
      //TODO: better message implementation
      //TODO: redo message & IO implementation
      //ignore:null_method
      var payloadStream = payload.listen((event) {});

      this.request = request;
      request.connection = this;
      request.rowCount = 0;
      request.rows = [];
      request.rst = [];

      dynamic onCancel() {
        payloadStream.asFuture(message);
        payloadStream.onError((e) {
          throw RequestError(message: 'Canceled.', code: 'ECANCEL');
        });

        // set the ignore bit and end the message.
        message.ignore = true;
        message.subscription.cancel();

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
      this.transitionTo(this.STATE['SENT_CLIENT_REQUEST']!);

      message.subscription.onDone(() {
        request.removeEventListener(
            EventListener('cancel', (val) {}, onCancel: onCancel));
        request.once('cancel', this._cancelAfterRequestSent);

        this.resetConnectionOnNextRequest = false;
        this.debug.payload(() {
          return payload.toString();
        });
      });

      payloadStream.onError((error) {
        payloadStream.asFuture(message);

        // Only set a request error if no error was set yet.
        request.error ??= error;

        message.ignore = true;
        message.subscription.cancel();
      });
      payloadStream.asFuture(message);
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
        callback: ({error, rowCount, rows}) {
          if (TDSVERSIONS[this.config!.options!.tdsVersion]! <
              TDSVERSIONS['7_2']!) {
            this.inTransaction = false;
          }
          callback(err: error);
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
