// // ignore_for_file: non_constant_identifier_names

// //TODO!
// import 'dart:async';

// import 'package:equatable/equatable.dart';
// import 'package:magic_buffer_copy/magic_buffer.dart';
// import 'package:tedious_dart/always_encrypted/keystore_provider_azure_key_vault.dart';
// import 'package:tedious_dart/conn_const_typedef.dart';
// import 'package:tedious_dart/connection.dart';
// import 'package:tedious_dart/conn_authentication.dart';
// import 'package:tedious_dart/message.dart';
// import 'package:tedious_dart/models/errors.dart';
// import 'package:tedious_dart/models/logger_stacktrace.dart';
// import 'package:tedious_dart/node/connection_m_classes.dart';
// import 'package:tedious_dart/ntlm_payload.dart';
// import 'package:tedious_dart/packet.dart';
// import 'package:tedious_dart/prelogin_payload.dart';
// import 'package:tedious_dart/request.dart';
// import 'package:tedious_dart/tds_versions.dart';
// import 'package:tedious_dart/token/handler.dart';

// /// String? name;
// ///  void enter({Connection? connection});
// ///  void exit({Connection? connection, State? newState});
// ///  void socketError({Connection? connection, Error? err});
// ///  void connectionTimeout({Connection? connection});
// ///  void message({Connection? connection, Message? message});
// ///  void retry({Connection? connection});
// ///  void reconnect({Connection? connection});

// //!objectLiteral class
// abstract class _StateEvents {
//   void Function([Connection? connection, Error? err])? get socketError;
//   void Function([Connection? connection])? get connectionTimeout;
//   void Function([Connection? connection, Message? message])? get message;
//   void Function([Connection? connection])? get retry;
//   void Function([Connection? connection])? get reconnect;

//   Map<String, dynamic> eventsMap() => {
//         "socketError": socketError,
//         "connectionTimeout": connectionTimeout,
//         "message": message,
//         "retry": retry,
//         "reconnect": reconnect,
//       };
// }

// class StateEvents extends _StateEvents {
//   @override
//   final void Function([Connection? connection, Error? err])? socketError;
//   @override
//   final void Function([Connection? connection])? connectionTimeout;
//   @override
//   final void Function([Connection? connection, Message? message])? message;
//   @override
//   final void Function([Connection? connection])? retry;
//   @override
//   final void Function([Connection? connection])? reconnect;

//   StateEvents({
//     this.socketError,
//     this.connectionTimeout,
//     this.message,
//     this.retry,
//     this.reconnect,
//   });
// }

// abstract class _State {
//   String name;
//   void Function([Connection? connection])? enter;
//   void Function([Connection? connection, State? newState])? exit;
//   StateEvents? events;
//   _State(
//     this.name, {
//     this.enter,
//     this.exit,
//     this.events,
//   });
// }

// // ignore: must_be_immutable
// class State extends _State implements Equatable {
//   State(
//     super.name, {
//     super.enter,
//     super.exit,
//     super.events,
//   });

//   @override
//   List<Object?> get props => [name];

//   @override
//   bool? get stringify => false;
// }

// //TODO: ??
// Map<String, State> STATES() {
//   // final c = Connection(null);
//   return {
//     "INITIALIZED": State('Initialized'),
//     "CONNECTING": State(
//       'Connecting',
//       enter: ([c]) {
//         c?.initialiseConnection();
//         print(LoggerStackTrace.from(StackTrace.current).toString());
//         console.log(['Connecting - enter']);
//       },
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//           print(LoggerStackTrace.from(StackTrace.current).toString());
//           console.log(['Connecting - socketError']);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//           print(LoggerStackTrace.from(StackTrace.current).toString());
//           console.log(['Connecting - connectionTimeout']);
//         },
//       ),
//     ),
//     "SENT_PRELOGIN": State(
//       'SentPrelogin',
//       enter: ([c]) {
//         () async {
//           var messageBuffer = Buffer.alloc(0);
//           late Message message;
//           try {
//             message = await c?.messageIo.readMessage();
//           } on Error catch (e, _) {
//             return c?.socketError(e);
//           }

//           await for (var data in message) {
//             messageBuffer = Buffer.concat([messageBuffer, data]);
//           }

//           final preloginPayload = PreloginPayload(messageBuffer);
//           c?.debug.payload(() {
//             return preloginPayload.toString(indent: '  ');
//           });

//           if (preloginPayload.fedAuthRequired == 1) {
//             c?.fedAuthRequired = true;
//           }

//           if (preloginPayload.encryptionString == 'ON' ||
//               preloginPayload.encryptionString == 'REQ') {
//             if (!c!.config.options.encrypt) {
//               c.emit(
//                   'connect',
//                   ConnectionError(
//                       "Server requires encryption, set 'encrypt' config option to true.",
//                       'EENCRYPT'));
//               return c.close();
//             }

//             try {
//               c.transitionTo(c.STATE['SENT_TLSSSLNEGOTIATION']!);
//               // await c.messageIo.startTls(
//               //     c.secureContextOptions,
//               //     c.routingData?.server ?? c.config.server,
//               //     c.routingData?.port as int,
//               //     c.config.options.trustServerCertificate);
//             } on Error catch (e) {
//               return c.socketError(e);
//             }
//           }
//           c?.sendLogin7Packet();

//           final authentication = c?.config.authentication;

//           switch (authentication?.type) {
//             case AuthType.azure_active_directory_password_:
//             case AuthType.azure_active_directory_msi_vm_:
//             case AuthType.azure_active_directory_msi_app_service_:
//             case AuthType.azure_active_directory_service_principal_secret_:
//             case AuthType.azure_active_directory_default_:
//               c?.transitionTo(c.STATE['SENT_LOGIN7_WITH_FEDAUTH']!);
//               break;
//             case AuthType.ntlm_:
//               c?.transitionTo(c.STATE['SENT_LOGIN7_WITH_NTLM']!);
//               break;
//             default:
//               c?.transitionTo(c.STATE['SENT_LOGIN7_WITH_STANDARD_LOGIN']!);
//               break;
//           }
//         }.call().catchError((e) {
//           scheduleMicrotask(() {
//             throw e;
//           });
//         });
//       },
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//       ),
//     ),
//     "REROUTING": State(
//       'ReRouting',
//       enter: ([c]) {
//         c?.cleanupConnection(CLEANUP_TYPE['REDIRECT']!);
//       },
//       events: StateEvents(
//         message: ([c, m]) {},
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         reconnect: ([c]) {
//           c?.transitionTo(c.STATE['CONNECTING']!);
//         },
//       ),
//     ),
//     "TRANSIENT_FAILURE_RETRY": State(
//       'TRANSIENT_FAILURE_RETRY',
//       enter: ([c]) {
//         c?.curTransientRetryCount++;
//         c?.cleanupConnection(CLEANUP_TYPE['RETRY']!);
//       },
//       events: StateEvents(
//         message: ([c, m]) {},
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         retry: ([c]) {
//           c?.createRetryTimer();
//         },
//       ),
//     ),
//     "SENT_TLSSSLNEGOTIATION": State(
//       'SentTLSSSLNegotiation',
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//       ),
//     ),
//     "SENT_LOGIN7_WITH_STANDARD_LOGIN": State(
//       'SentLogin7WithStandardLogin',
//       enter: ([c]) {
//         () async {
//           late Message message;
//           try {
//             message = await c?.messageIo.readMessage();
//           } on Error catch (e) {
//             return c?.socketError(e);
//           }
//           final handler = Login7TokenHandler(c!);
//           final tokenStreamParser = c.createTokenStreamParser(message, handler);

//           // await c.once('end', tokenStreamParser);
//           await tokenStreamParser.once('end');

//           if (handler.loginAckReceived) {
//             if (handler.routingData != null) {
//               c.routingData = handler.routingData;
//               c.transitionTo(c.STATE['REROUTING']!);
//             } else {
//               c.transitionTo(c.STATE['LOGGED_IN_SENDING_INITIAL_SQL']!);
//             }
//           } else if (c.loginError != null) {
//             if (isTransientError(c.loginError)) {
//               c.debug.log('Initiating retry on transient error');
//               c.transitionTo(c.STATE['TRANSIENT_FAILURE_RETRY']!);
//             } else {
//               c.emit('connect', c.loginError);
//               c.transitionTo(c.STATE['FINAL']!);
//             }
//           } else {
//             c.emit('connect', ConnectionError('Login failed.', 'ELOGIN'));
//             c.transitionTo(c.STATE['FINAL']!);
//           }
//         }.call().catchError((e) {
//           scheduleMicrotask(() {
//             throw e;
//           });
//         });
//       },
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//       ),
//     ),
//     "SENT_LOGIN7_WITH_NTLM": State(
//       'SentLogin7WithNTLMLogin',
//       enter: ([c]) {
//         () async {
//           while (true) {
//             late Message message;
//             try {
//               message = await c?.messageIo.readMessage();
//             } on Error catch (e) {
//               return c?.socketError(e);
//             }

//             final handler = Login7TokenHandler(c!);
//             final tokenStreamParser =
//                 c.createTokenStreamParser(message, handler);

//             await tokenStreamParser.once('end');

//             // await c.once('end', (_) => tokenStreamParser);

//             if (handler.loginAckReceived) {
//               if (handler.routingData != null) {
//                 c.routingData = handler.routingData;
//                 return c.transitionTo(c.STATE['REROUTING']!);
//               } else {
//                 return c
//                     .transitionTo(c.STATE['LOGGED_IN_SENDING_INITIAL_SQL']!);
//               }
//             } else if (c.ntlmpacket != null) {
//               final authentication =
//                   c.config.authentication as NtlmAuthentication;

//               final payload = NTLMResponsePayload(
//                 data: null,
//                 loginData: NTLMOptions(
//                     domain: authentication.options.domain,
//                     userName: authentication.options.userName,
//                     password: authentication.options.password,
//                     ntlmpacket: c.ntlmpacket),
//               );

//               c.messageIo
//                   .sendMessage(PACKETTYPE['NTLMAUTH_PKT']!, data: payload.data);
//               c.debug.payload(() {
//                 return payload.toString(indent: '  ');
//               });

//               c.ntlmpacket = null;
//             } else if (c.loginError != null) {
//               if (isTransientError(c.loginError)) {
//                 c.debug.log('Initiating retry on transient error');
//                 return c.transitionTo(c.STATE['TRANSIENT_FAILURE_RETRY']!);
//               } else {
//                 c.emit('connect', c.loginError);
//                 return c.transitionTo(c.STATE['FINAL']!);
//               }
//             } else {
//               c.emit('connect', ConnectionError('Login failed.', 'ELOGIN'));
//               return c.transitionTo(c.STATE['FINAL']!);
//             }
//           }
//         }.call().catchError((e) {
//           scheduleMicrotask(() {
//             throw e;
//           });
//         });
//       },
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//       ),
//     ),
//     "SENT_LOGIN7_WITH_FEDAUTH": State(
//       'SentLogin7Withfedauth',
//       enter: ([c]) {
//         () async {
//           late Message message;
//           try {
//             message = await c?.messageIo.readMessage();
//           } on Error catch (e) {
//             return c?.socketError(e);
//           }

//           final handler = Login7TokenHandler(c!);
//           final tokenStreamParser = c.createTokenStreamParser(message, handler);
//           // await c.once('end', tokenStreamParser);
//           await tokenStreamParser.once('end');

//           if (handler.loginAckReceived) {
//             if (handler.routingData != null) {
//               c.routingData = handler.routingData;
//               c.transitionTo(c.STATE['REROUTING']!);
//             } else {
//               c.transitionTo(c.STATE['LOGGED_IN_SENDING_INITIAL_SQL']!);
//             }

//             return;
//           }
//           final fedAuthInfoToken = handler.fedAuthInfoToken;

//           if (fedAuthInfoToken != null &&
//               fedAuthInfoToken.stsurl != null &&
//               fedAuthInfoToken.spn != null) {
//             final authentication = c.config.authentication;
//             final tokenScope =
//                 Uri(path: '/.default', pathSegments: [fedAuthInfoToken.spn!])
//                     .toString();

//             dynamic credentials;

//             switch (authentication.type) {
//               case AuthType.azure_active_directory_password_:
//                 credentials = UsernamePasswordCredential(
//                     authentication.options.tenantId ?? 'common',
//                     authentication.options.clientId,
//                     authentication.options.userName,
//                     authentication.options.password);
//                 break;
//               case AuthType.azure_active_directory_msi_vm_:
//               case AuthType.azure_active_directory_msi_app_service_:
//                 final msiArgs = authentication.options.clientId == null
//                     ? [authentication.options.clientId, {}]
//                     : [{}];
//                 credentials = ManagedIdentityCredential(msiArgs);
//                 break;
//               case AuthType.azure_active_directory_default_:
//                 final args = authentication.options.clientId == null
//                     ? {
//                         'managedIdentityClientId':
//                             authentication.options.clientId
//                       }
//                     : {};
//                 credentials = DefaultAzureCredential(args);
//                 break;
//               case AuthType.azure_active_directory_service_principal_secret_:
//                 credentials = ClientSecretCredential(
//                   authentication.options.clientId!,
//                   authentication.options.clientSecret!,
//                   authentication.options.tenantId!,
//                 );
//                 break;
//               default:
//             }

//             dynamic tokenResponse;
//             try {
//               tokenResponse = await credentials.getToken(tokenScope);
//             } catch (err) {
//               c.loginError = ConnectionError(
//                   'Security token could not be authenticated or authorized.',
//                   'EFEDAUTH');
//               c.emit('connect', c.loginError);
//               c.transitionTo(c.STATE['FINAL']!);
//               return;
//             }

//             final token = tokenResponse.token;
//             c.sendFedAuthTokenMessage(token);
//           } else if (c.loginError != null) {
//             if (isTransientError(c.loginError)) {
//               c.debug.log('Initiating retry on transient error');
//               c.transitionTo(c.STATE['TRANSIENT_FAILURE_RETRY']!);
//             } else {
//               c.emit('connect', c.loginError);
//               c.transitionTo(c.STATE['FINAL']!);
//             }
//           } else {
//             c.emit('connect', ConnectionError('Login failed.', 'ELOGIN'));
//             c.transitionTo(c.STATE['FINAL']!);
//           }
//         }.call().catchError((e) {
//           scheduleMicrotask(() {
//             throw e;
//           });
//         });
//       },
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//       ),
//     ),
//     "LOGGED_IN_SENDING_INITIAL_SQL": State(
//       'LoggedInSendingInitialSql',
//       enter: ([c]) {
//         () async {
//           c?.sendInitialSql();
//           late Message message;
//           try {
//             message = await c?.messageIo.readMessage();
//           } on Error catch (e) {
//             return c?.socketError(e);
//           }
//           final tokenStreamParser =
//               c?.createTokenStreamParser(message, InitialSqlTokenHandler(c));
//           // await c?.once('end', tokenStreamParser);
//           await tokenStreamParser?.once('end');

//           c?.transitionTo(c.STATE['LOGGED_IN']!);
//           c?.processedInitialSql();
//         }()
//             .catchError((e) {
//           scheduleMicrotask(() {
//             throw e;
//           });
//         });
//       },
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//         connectionTimeout: ([c]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//       ),
//     ),
//     "LOGGED_IN": State(
//       'LoggedIn',
//       events: StateEvents(
//         socketError: ([c, e]) {
//           c?.transitionTo(c.STATE['FINAL']!);
//         },
//       ),
//     ),
//     "SENT_CLIENT_REQUEST": State(
//       'SentClientRequest',
//       enter: ([c]) {
//         () async {
//           late Message message;
//           try {
//             message = await c?.messageIo.readMessage();
//           } on Error catch (e) {
//             return c?.socketError(e);
//           }
//           c?.clearRequestTimer();

//           final tokenStreamParser = c?.createTokenStreamParser(
//               message,
//               RequestTokenHandler(
//                 c,
//                 c.request!,
//                 [],
//               ));

//           if (c?.request?.canceled && c?.cancelTimer != null) {
//             return c?.transitionTo(c.STATE['SENT_ATTENTION']!);
//           }
//           onResume() {
//             tokenStreamParser?.resume();
//           }

//           onPause() {
//             tokenStreamParser?.pause();

//             c?.request?.once('resume', onResume);
//           }

//           c?.request?.on('pause', onPause);

//           if (c?.request is Request && c?.request.paused) {
//             onPause();
//           }

//           onEndOfMessage() {
//             c?.request?.removeListener('cancel', c.cancelAfterRequestSent);

//             //TODO:ignore:referenced_before_declaration

//             // c.request?.removeListener('cancel', onCancel);
//             c?.request?.removeListener('pause', onPause);
//             c?.request?.removeListener('resume', onResume);

//             c?.transitionTo(c.STATE['LOGGED_IN']!);
//             final sqlRequest = c?.request as Request;
//             c?.request = null;
//             if (TDSVERSIONS[c?.config.options.tdsVersion]! <
//                     TDSVERSIONS['7_2']! &&
//                 sqlRequest.error != null &&
//                 c!.isSqlBatch) {
//               c.inTransaction = false;
//             }
//             sqlRequest.callback(
//               sqlRequest.error,
//               sqlRequest.rowCount,
//               sqlRequest.rows,
//             );
//           }

//           onCancel() {
//             // tokenStreamParser.removeListener('end', onEndOfMessage);

//             if (c?.request is Request && c?.request.paused) {
//               // resume the request if it was paused so we can read the remaining tokens
//               c?.request.resume();
//             }

//             c?.request?.removeListener('pause', onPause);
//             c?.request?.removeListener('resume', onResume);

//             // The `_cancelAfterRequestSent` callback will have sent a
//             // attention message, so now we need to also switch to
//             // the `SENT_ATTENTION` state to make sure the attention ack
//             // message is processed correctly.
//             c?.transitionTo(c.STATE['SENT_ATTENTION']!);
//           }

//           tokenStreamParser?.once('end', (_) => onEndOfMessage);

//           // c.request?.once('cancel', onCancel);
//         }.call();
//       },
//       exit: ([c, s]) {
//         c?.clearRequestTimer();
//       },
//       events: StateEvents(
//         socketError: ([c, err]) {
//           final sqlRequest = c?.request!;
//           c?.request = null;
//           c?.transitionTo(c.STATE['FINAL']!);

//           sqlRequest.callback(err);
//         },
//       ),
//     ),
//     "SENT_ATTENTION": State(
//       'SentAttention',
//       enter: ([c]) {
//         () async {
//           late Message message;
//           try {
//             message = await c?.messageIo.readMessage();
//           } on Error catch (e) {
//             return c?.socketError(e);
//           }

//           final handler = AttentionTokenHandler(c!, c.request!);
//           final tokenStreamParser = c.createTokenStreamParser(message, handler);

//           // await c.once('end', tokenStreamParser);
//           await tokenStreamParser.once('end');

//           // 3.2.5.7 Sent Attention State
//           // Discard any data contained in the response, until we receive the attention response
//           if (handler.attentionReceived) {
//             c.clearCancelTimer();

//             final sqlRequest = c.request! as Request;
//             c.request = null;
//             c.transitionTo(c.STATE['LOGGED_IN']!);

//             if (sqlRequest.error != null &&
//                 sqlRequest.error is RequestError &&
//                 sqlRequest.error!.code == 'ETIMEOUT') {
//               sqlRequest.callback(sqlRequest.error);
//             } else {
//               sqlRequest.callback(
//                   RequestError(message: 'Canceled.', code: 'ECANCEL'));
//             }
//           }
//         }()
//             .catchError((e) {
//           scheduleMicrotask(() {
//             throw e;
//           });
//         });
//       },
//       events: StateEvents(
//         socketError: ([c, err]) {
//           final sqlRequest = c?.request!;
//           c?.request = null;

//           c?.transitionTo(c.STATE['FINAL']!);

//           sqlRequest.callback(err);
//         },
//       ),
//     ),
//     "FINAL": State(
//       'Final',
//       enter: ([c]) {
//         c?.cleanupConnection(CLEANUP_TYPE['NORMAL']!);
//       },
//       events: StateEvents(
//         connectionTimeout: ([c]) {
//           // Do nothing, as the timer should be cleaned up.
//         },
//         message: ([c, m]) {
//           // Do nothing
//         },
//         socketError: ([c, e]) {
//           // Do nothing
//         },
//       ),
//     ),
//   };
// }
