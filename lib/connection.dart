// ignore_for_file: constant_identifier_names, library_private_types_in_public_api,  unnecessary_null_comparison, unnecessary_type_check

import 'dart:async';
import 'dart:io';

import 'package:events_emitter/events_emitter.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/bulk_load.dart';
import 'package:tedious_dart/bulk_load_payload.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/conn_authentication.dart';
import 'package:tedious_dart/conn_config.dart';
import 'package:tedious_dart/conn_const_typedef.dart';
import 'package:tedious_dart/conn_states.dart';
import 'package:tedious_dart/connector.dart';
import 'package:tedious_dart/data_types/int.dart';
import 'package:tedious_dart/data_types/nvarchar.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/extensions/to_iterable_on_stream.dart';
import 'package:tedious_dart/instance_lookup.dart';
import 'package:tedious_dart/library.dart';
import 'package:tedious_dart/login7_payload.dart';
import 'package:tedious_dart/message.dart';
import 'package:tedious_dart/message_io.dart';
import 'package:tedious_dart/meta/annotations.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/random_bytes.dart';
import 'package:tedious_dart/node/abort_controller.dart';
import 'package:tedious_dart/ntlm.dart';
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

  ConnectionConfiguration config;

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
  late Map<String, State> STATE;

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

  late void Function() cancelAfterRequestSent;

  Collation? databaseCollation;

  Connection(this.config) : super() {
    STATE = STATES(this);
    //
    if (config.runtimeType != Object || config == null) {
      throw MTypeError(
          'The "config" argument is required and must be of type Object.');
    }

    if (config.server.runtimeType != String) {
      throw MTypeError(
          'The "config.server" property is required and must be of type string.');
    }

    fedAuthRequired = false;

    AuthenticationType authentication;
    if (config.authentication != null) {
      if (config.authentication.runtimeType != Object ||
          config.authentication == null) {
        throw MTypeError(
            'The "config.authentication" property must be of type Object.');
      }

      var type = config.authentication.type;
      var options = config.authentication.options;

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
        authentication = AuthenticationType(
          type: type,
          options: options,
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
        authentication = AuthenticationType(
          type: type,
          options: options,
        );
      }
      //!
      else if (type == 'azure-active-directory-access-token') {
        if (options.token.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.token" property must be of type string.');
        }
        authentication = AuthenticationType(
          type: type,
          options: options,
        );
      }
      //!
      else if (type == 'azure-active-directory-msi-vm') {
        if (options.clientId != null &&
            options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }
        authentication = AuthenticationType(
          type: type,
          options: options,
        );
      }
      //!
      else if (type == 'azure-active-directory-default') {
        if (options.clientId != null &&
            options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }
        authentication = AuthenticationType(
          type: type,
          options: options,
        );
      }
      //!
      else if (type == 'azure-active-directory-msi-app-service') {
        if (options.clientId != null &&
            options.clientId.runtimeType != String) {
          throw MTypeError(
              'The "config.authentication.options.clientId" property must be of type string.');
        }
        authentication = AuthenticationType(
          type: type,
          options: options,
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
        authentication = AuthenticationType(
          type: type,
          options: options,
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
        authentication = AuthenticationType(
          type: type,
          options: options,
        );
      }
    } else {
      authentication =
          AuthenticationType(type: 'default', options: AuthOptions());
    }

    //! i think that these are useless type checks
    if (config.options != null) {
      if (config.options.port != null && config.options.instanceName != null) {
        throw MTypeError(
            'Port and instanceName are mutually exclusive, but   ${config.options.port}  and   ${config.options.instanceName}  provided');
      }

      if (config.options.abortTransactionOnError != null) {
        if (config.options.abortTransactionOnError is! bool &&
            config.options.abortTransactionOnError != null) {
          throw MTypeError(
              'The "config!.options!.abortTransactionOnError" property must be of type bool.');
        }
      }

      if (config.options.appName != null) {
        if (config.options.appName is! String) {
          throw MTypeError(
              'The "config!.options!.appName" property must be of type string.');
        }
      }

      if (config.options.camelCaseColumns != null) {
        if (config.options.camelCaseColumns is! bool) {
          throw MTypeError(
              'The "config!.options!.camelCaseColumns" property must be of type boolean.');
        }
      }

      if (config.options.cancelTimeout != null) {
        if (config.options.cancelTimeout is! num) {
          throw MTypeError(
              'The "config!.options!.cancelTimeout" property must be of type number.');
        }
      }

      if (config.options.columnNameReplacer != null) {
        if (config.options.columnNameReplacer is! Function) {
          throw MTypeError(
              'The "config!.options!.cancelTimeout" property must be of type function.');
        }
      }

      if (config.options.connectionIsolationLevel != null) {
        assertValidIsolationLevel(config.options.connectionIsolationLevel,
            'config!.options!.connectionIsolationLevel');
      }

      if (config.options.connectTimeout != null) {
        if (config.options.connectTimeout is! num) {
          throw MTypeError(
              'The "config!.options!.connectTimeout" property must be of type number.');
        }
      }

      if (config.options.cryptoCredentialsDetails != null) {
        if (config.options.cryptoCredentialsDetails is! SecurityContext ||
            config.options.cryptoCredentialsDetails == null) {
          throw MTypeError(
              'The "config!.options!.cryptoCredentialsDetails" property must be of type Object.');
        }
      }

      if (config.options.database != null) {
        if (config.options.database is! String) {
          throw MTypeError(
              'The "config!.options!.database" property must be of type string.');
        }
      }

      if (config.options.datefirst != null) {
        if (config.options.datefirst is! num &&
            config.options.datefirst != null) {
          throw MTypeError(
              'The "config!.options!.datefirst" property must be of type number.');
        }

        if (config.options.datefirst != null &&
            (config.options.datefirst! < 1 || config.options.datefirst! > 7)) {
          throw RangeError(
              'The "config!.options!.datefirst" property must be >= 1 and <= 7');
        }
      }

      if (config.options.dateFormat != null) {
        if (config.options.dateFormat is! String &&
            config.options.dateFormat != null) {
          throw MTypeError(
              'The "config!.options!.dateFormat" property must be of type string or null.');
        }
      }

      if (config.options.debug != null) {
        if (config.options.debug!.data != null) {
          if (config.options.debug!.data is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.data" property must be of type boolean.');
          }
        }

        if (config.options.debug!.packet != null) {
          if (config.options.debug!.packet is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.packet" property must be of type boolean.');
          }
        }

        if (config.options.debug!.payload != null) {
          if (config.options.debug!.payload is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.payload" property must be of type boolean.');
          }
        }

        if (config.options.debug!.token != null) {
          if (config.options.debug!.token is! bool) {
            throw MTypeError(
                'The "config!.options!.debug.token" property must be of type boolean.');
          }
        }
      }

      if (config.options.enableAnsiNull != null) {
        if (config.options.enableAnsiNull is! bool &&
            config.options.enableAnsiNull != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiNull" property must be of type boolean or null.');
        }
      }

      if (config.options.enableAnsiNullDefault != null) {
        if (config.options.enableAnsiNullDefault is! bool &&
            config.options.enableAnsiNullDefault != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiNullDefault" property must be of type boolean or null.');
        }
      }

      if (config.options.enableAnsiPadding != null) {
        if (config.options.enableAnsiPadding is! bool &&
            config.options.enableAnsiPadding != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiPadding" property must be of type boolean or null.');
        }
      }

      if (config.options.enableAnsiWarnings != null) {
        if (config.options.enableAnsiWarnings is! bool &&
            config.options.enableAnsiWarnings != null) {
          throw MTypeError(
              'The "config!.options!.enableAnsiWarnings" property must be of type boolean or null.');
        }
      }

      if (config.options.enableArithAbort != null) {
        if (config.options.enableArithAbort is! bool &&
            config.options.enableArithAbort != null) {
          throw MTypeError(
              'The "config!.options!.enableArithAbort" property must be of type boolean or null.');
        }
      }

      if (config.options.enableConcatNullYieldsNull != null) {
        if (config.options.enableConcatNullYieldsNull is! bool &&
            config.options.enableConcatNullYieldsNull != null) {
          throw MTypeError(
              'The "config!.options!.enableConcatNullYieldsNull" property must be of type boolean or null.');
        }
      }

      if (config.options.enableCursorCloseOnCommit != null) {
        if (config.options.enableCursorCloseOnCommit is! bool &&
            config.options.enableCursorCloseOnCommit != null) {
          throw MTypeError(
              'The "config!.options!.enableCursorCloseOnCommit" property must be of type boolean or null.');
        }
      }

      if (config.options.enableImplicitTransactions != null) {
        if (config.options.enableImplicitTransactions is! bool &&
            config.options.enableImplicitTransactions != null) {
          throw MTypeError(
              'The "config!.options!.enableImplicitTransactions" property must be of type boolean or null.');
        }
      }

      if (config.options.enableNumericRoundabort != null) {
        if (config.options.enableNumericRoundabort is! bool &&
            config.options.enableNumericRoundabort != null) {
          throw MTypeError(
              'The "config!.options!.enableNumericRoundabort" property must be of type boolean or null.');
        }
      }

      if (config.options.enableQuotedIdentifier != null) {
        if (config.options.enableQuotedIdentifier is! bool &&
            config.options.enableQuotedIdentifier != null) {
          throw MTypeError(
              'The "config!.options!.enableQuotedIdentifier" property must be of type boolean or null.');
        }
      }

      if (config.options.encrypt != null) {
        if (config.options.encrypt is! bool) {
          throw MTypeError(
              'The "config!.options!.encrypt" property must be of type boolean.');
        }
      }

      if (config.options.fallbackToDefaultDb != null) {
        if (config.options.fallbackToDefaultDb is! bool) {
          throw MTypeError(
              'The "config!.options!.fallbackToDefaultDb" property must be of type boolean.');
        }
      }

      if (config.options.instanceName != null) {
        if (config.options.instanceName is! String) {
          throw MTypeError(
              'The "config!.options!.instanceName" property must be of type string.');
        }
      }

      if (config.options.isolationLevel != null) {
        assertValidIsolationLevel(
            config.options.isolationLevel, 'config!.options!.isolationLevel');
      }

      if (config.options.language != null) {
        if (config.options.language is! String &&
            config.options.language != null) {
          throw MTypeError(
              'The "config!.options!.language" property must be of type string or null.');
        }
      }

      if (config.options.localAddress != null) {
        if (config.options.localAddress is! String) {
          throw MTypeError(
              'The "config!.options!.localAddress" property must be of type string.');
        }
      }

      if (config.options.multiSubnetFailover != null) {
        if (config.options.multiSubnetFailover is! bool) {
          throw MTypeError(
              'The "config!.options!.multiSubnetFailover" property must be of type boolean.');
        }
      }

      if (config.options.packetSize != null) {
        if (config.options.packetSize is! num) {
          throw MTypeError(
              'The "config!.options!.packetSize" property must be of type number.');
        }
      }

      if (config.options.port != null) {
        if (config.options.port is! num) {
          throw MTypeError(
              'The "config!.options!.port" property must be of type number.');
        }

        if (config.options.port! <= 0 || config.options.port! >= 65536) {
          throw RangeError(
              'The "config!.options!.port" property must be > 0 and < 65536');
        }
      }

      if (config.options.readOnlyIntent != null) {
        if (config.options.readOnlyIntent is! bool) {
          throw MTypeError(
              'The "config!.options!.readOnlyIntent" property must be of type boolean.');
        }
      }

      if (config.options.requestTimeout != null) {
        if (config.options.requestTimeout is! num) {
          throw MTypeError(
              'The "config!.options!.requestTimeout" property must be of type number.');
        }
      }

      if (config.options.maxRetriesOnTransientErrors != null) {
        if (config.options.maxRetriesOnTransientErrors is! num) {
          throw MTypeError(
              'The "config!.options!.maxRetriesOnTransientErrors" property must be of type number.');
        }

        if (config.options.maxRetriesOnTransientErrors < 0) {
          throw MTypeError(
              'The "config!.options!.maxRetriesOnTransientErrors" property must be equal or greater than 0.');
        }
      }

      if (config.options.connectionRetryInterval != null) {
        if (config.options.connectionRetryInterval is! num) {
          throw MTypeError(
              'The "config!.options!.connectionRetryInterval" property must be of type number.');
        }

        if (config.options.connectionRetryInterval <= 0) {
          throw MTypeError(
              'The "config!.options!.connectionRetryInterval" property must be greater than 0.');
        }
      }

      if (config.options.rowCollectionOnDone != null) {
        if (config.options.rowCollectionOnDone is! bool) {
          throw MTypeError(
              'The "config!.options!.rowCollectionOnDone" property must be of type boolean.');
        }
      }

      if (config.options.rowCollectionOnRequestCompletion != null) {
        if (config.options.rowCollectionOnRequestCompletion is! bool) {
          throw MTypeError(
              'The "config!.options!.rowCollectionOnRequestCompletion" property must be of type boolean.');
        }
      }

      if (config.options.tdsVersion != null) {
        if (config.options.tdsVersion is! String) {
          throw MTypeError(
              'The "config!.options!.tdsVersion" property must be of type string.');
        }
      }

      if (config.options.textsize != null) {
        if (config.options.textsize is! num &&
            config.options.textsize != null) {
          throw MTypeError(
              'The "config!.options!.textsize" property must be of type number or null.');
        }

        if (config.options.textsize > 2147483647) {
          throw MTypeError(
              'The "config!.options!.textsize" can\'t be greater than 2147483647.');
        } else if (config.options.textsize < -1) {
          throw MTypeError(
              'The "config!.options!.textsize" can\'t be smaller than -1.');
        }
      }

      if (config.options.trustServerCertificate != null) {
        if (config.options.trustServerCertificate is! bool) {
          throw MTypeError(
              'The "config!.options!.trustServerCertificate" property must be of type boolean.');
        }
      }

      if (config.options.useColumnNames != null) {
        if (config.options.useColumnNames is! bool) {
          throw MTypeError(
              'The "config!.options!.useColumnNames" property must be of type boolean.');
        }
      }

      if (config.options.useUTC != null) {
        if (config.options.useUTC is! bool) {
          throw MTypeError(
              'The "config!.options!.useUTC" property must be of type boolean.');
        }
      }

      if (config.options.workstationId != null) {
        if (config.options.workstationId is! String) {
          throw MTypeError(
              'The "config!.options!.workstationId" property must be of type string.');
        }
      }

      if (config.options.lowerCaseGuids != null) {
        if (config.options.lowerCaseGuids is! bool) {
          throw MTypeError(
              'The "config!.options!.lowerCaseGuids" property must be of type boolean.');
        }
      }
    }
    debug = createDebug();
    inTransaction = false;
    transactionDescriptors = [
      Buffer.from([0, 0, 0, 0, 0, 0, 0, 0])
    ];
    // 'beginTransaction', 'commitTransaction' and 'rollbackTransaction'
    // events are utilized to maintain inTransaction property state which in
    // turn is used in managing transactions. These events are only fired for
    // TDS version 7.2 and beyond. The properties below are used to emulate
    // equivalent behavior for TDS versions before 7.2.
    transactionDepth = 0;
    isSqlBatch = false;
    closed = false;
    messageBuffer = Buffer.alloc(0);
    curTransientRetryCount = 0;
    transientErrorLookup = TransientErrorLookup();
    state = STATE['INITIALIZED']!;
    cancelAfterRequestSent = () {
      messageIo.sendMessage(PACKETTYPE['ATTENTION']!);
      createCancelTimer();
    };
    //TODO! end of constructor
  }

  connect([void Function(Error error)? connectListener]) {
    if (state != STATE['INITIALIZED']!) {
      throw ConnectionError(
          '`.connect` can not be called on a Connection in `${state!.name}` state.');
    }

    if (connectListener != null) {
      onError(Error err) {
        removeEventListener(EventListener('connect', (error) {}));
        connectListener(err);
      }

      onConnect(Error err) {
        removeEventListener(EventListener('error', onError));
        connectListener(err);
      }

      once('connect', onConnect);
      once('error', onError);
    }

    transitionTo(STATE['CONNECTING']!);
  }

  close() {
    transitionTo(STATE['FINAL']!);
  }

  initialiseConnection() {
    final signal = createConnectTimer();

    if (config.options.port != null) {
      return connectOnPort(
        config.options.port!,
        config.options.multiSubnetFailover,
        signal,
      );
    } else {
      return instanceLookup(InstanceLookUpOptions(
        server: config.server,
        instanceName: config.options.instanceName!,
        timeout: config.options.connectTimeout,
        signal: signal,
      )).then((port) {
        scheduleMicrotask(() {
          connectOnPort(
            port,
            config.options.multiSubnetFailover,
            signal,
          );
        });
      }).catchError((err) {
        clearConnectTimer();
        if (err.name == 'AbortError') {
          // Ignore the AbortError for now, this is still handled by the connectTimer firing
          return;
        }
        scheduleMicrotask(() {
          emit('connect', ConnectionError(err.message, 'EINSTLOOKUP'));
        });
      });
    }
  }

  cleanupConnection(int cleanupType) {
    if (!closed) {
      clearConnectTimer();
      clearRequestTimer();
      clearRetryTimer();
      closeConnection();
      if (cleanupType == CLEANUP_TYPE['REDIRECT']) {
        emit('rerouting');
      } else if (cleanupType != CLEANUP_TYPE['RETRY']) {
        scheduleMicrotask(() {
          emit('end');
        });
      }

      final request = this.request;
      if (request) {
        final err = RequestError(
            message: 'Connection closed before request completed.',
            code: 'ECLOSE');
        request.callback(err);
        this.request = null;
      }

      closed = true;
      loginError = null;
    }
  }

  createDebug() {
    final debug = Debug(options: config.options.debug!);
    debug.on('debug', (message) {
      emit('debug', message);
    });
    return debug;
  }

  createTokenStreamParser(Message message, TokenHandler handler) {
    return TokenStreamParser(
      //TODO:
      message: message,
      debug: debug,
      tokenHandler: handler,
      options: ParserOptions(
        camelCaseColumns: config.options.camelCaseColumns,
        columnNameReplacer: config.options.columnNameReplacer,
        lowerCaseGuids: config.options.lowerCaseGuids,
        tdsVersion: config.options.tdsVersion,
        useColumnNames: config.options.useColumnNames,
        useUTC: config.options.useUTC,
      ),
    );
  }

  connectOnPort(num port, bool multiSubnetFailover, AbortSignal signal) {
    //TODO:
    final connectOpts = {
      'host': routingData != null ? routingData!.server : config.server,
      'port': routingData != null ? routingData!.port : port,
      'localAddress': config.options.localAddress,
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
        messageIo = MessageIO(
          socket,
          config.options.packetSize,
          debug,
        );
        messageIo.on('secure', (cleartext) => {emit('secure', cleartext)});

        this.socket = socket;
        closed = false;
        debug.log('connected to ${config.server}:${config.options.port}');

        sendPreLogin();
        transitionTo(STATE['SENT_PRELOGIN']!);
      });
      //TODO!!!!!!: socket.on('event', (){});
    });
  }

  closeConnection() {
    if (socket != null) {
      socket!.destroy();
    }
  }

  createConnectTimer() {
    final controller = AbortController();
    connectTimer = Timer(
      Duration(
        seconds: config.options.connectTimeout,
      ),
      () {
        controller.abort();
        connectTimeout();
      },
    );
    return controller.signal;
  }

  createCancelTimer() {
    clearCancelTimer();
    final timeout = config.options.cancelTimeout;
    if (timeout > 0) {
      cancelTimer = Timer(
        Duration(seconds: timeout),
        () {
          cancelTimeout();
        },
      );
    }
  }

  createRequestTimer() {
    clearRequestTimer(); // release old timer, just to be safe
    final request = this.request as Request;
    final timeout = (request.timeout != null)
        ? request.timeout
        : config.options.requestTimeout;
    if (timeout != null) {
      // this.requestTimer = setTimeout(() => {
      //   this.requestTimeout();
      // }, timeout);
      requestTimer = Timer(
        Duration(seconds: timeout as int),
        () {
          requestTimeout();
        },
      );
    }
  }

  createRetryTimer() {
    clearRetryTimer();
    retryTimer = Timer(
      Duration(seconds: config.options.connectionRetryInterval),
      () {
        retryTimeout();
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
    Failed to connect to ${config.server} ${config.options.port == null ? config.options.port : config.options.instanceName} in ${config.options.connectTimeout} ms
    """;
    debug.log(message);
    emit('connect', ConnectionError(message, 'ETIMEOUT'));
    connectTimer = null;
    dispatchEvent('connectTimeout');
  }

  cancelTimeout() {
    final message =
        'Failed to cancel request in ${config.options.cancelTimeout}ms';
    debug.log(message);
    dispatchEvent('socketError', ConnectionError(message, 'ETIMEOUT'));
  }

  requestTimeout() {
    requestTimer = null;
    final request = this.request!;
    request.cancel();
    final timeout = (request.timeout != null)
        ? request.timeout
        : config.options.requestTimeout;
    final message = 'Timeout: Request failed to complete in $timeout ms';
    request.error = RequestError(message: message, code: 'ETIMEOUT');
  }

  retryTimeout() {
    retryTimer = null;
    emit('retry');
    transitionTo(STATE['CONNECTING']!);
  }

  clearConnectTimer() {
    if (connectTimer != null) {
      connectTimer!.cancel();
      // clearTimeout(this.connectTimer);
      connectTimer = null;
    }
  }

  clearCancelTimer() {
    if (cancelTimer != null) {
      cancelTimer!.cancel();
      // clearTimeout(this.cancelTimer);
      cancelTimer = null;
    }
  }

  clearRequestTimer() {
    if (requestTimer != null) {
      requestTimer!.cancel();
      // clearTimeout(this.requestTimer);
      requestTimer = null;
    }
  }

  clearRetryTimer() {
    if (retryTimer != null) {
      retryTimer!.cancel();
      // clearTimeout(this.retryTimer);
      retryTimer = null;
    }
  }

  transitionTo(State newState) {
    if (state == newState) {
      debug.log('State is already ${newState.name}');
      return;
    }

    if (state != null && state!.exit != null) {
      state!.exit!(this, newState);
    }

    debug.log(
        'State change: ${state != null ? state!.name : 'null'} -> ${newState.name}');
    state = newState;

    if (state!.enter != null) {
      Function.apply(state!.enter!, [this]);
    }
  }

  getEventHandler(String eventName) {
    final handler = State.eventsMap[eventName];
    if (handler == null) {
      throw MTypeError("No event '$eventName' in state '${state!.name}'");
    }
    return handler;
  }

  dispatchEvent(String eventName, [dynamic args]) {
    final handler = State.eventsMap[eventName] as void Function(
        Connection? connection, dynamic args)?;
    if (handler != null) {
      Function.apply(handler, [this, args]);
      // handler(this, args);
    } else {
      emit('error',
          MTypeError("No event '$eventName' in state '${state!.name}"));
      close();
    }
  }

  socketError(Error error) {
    if (state == STATE['CONNECTING'] ||
        state == STATE['SENT_TLSSSLNEGOTIATION']) {
      final message =
          'Failed to connect to ${config.server}:${config.options.port} - ${error.toString()}';
      debug.log(message);
      emit('connect', ConnectionError(message, 'ESOCKET'));
    } else {
      final message = 'Connection lost - ${error.toString()}';
      debug.log(message);
      emit('error', ConnectionError(message, 'ESOCKET'));
    }
    dispatchEvent('socketError', error);
  }

  socketEnd() {
    debug.log('socket ended');
    if (state != STATE['FINAL']) {
      final error = ConnectionError('socket hang up');
      error.code = 'ECONNRESET';
      socketError(error);
    }
  }

  socketClose() {
    debug.log('connection to ${config.server}:${config.options.port} closed');
    if (state == STATE['REROUTING']) {
      debug.log('Rerouting to ${routingData!.server}:${routingData!.port}');

      dispatchEvent('reconnect');
    } else if (state == STATE['TRANSIENT_FAILURE_RETRY']) {
      final server = routingData != null ? routingData!.server : config.server;
      final port =
          routingData != null ? routingData!.port : config.options.port;
      debug.log('Retry after transient failure connecting to ${server}:$port');

      dispatchEvent('retry');
    } else {
      transitionTo(STATE['FINAL']!);
    }
  }

  sendPreLogin() {
    // final [, major, minor, build] = /^(\d+)\.(\d+)\.(\d+)/.exec(version) ?? ['0.0.0', '0', '0', '0'];
    final major = '0.0.0';
    final minor = '0';
    final build = '0';
    final subbuild = '0';
    final payload = PreloginPayload(
      PreloginPayloadOptions(
        encrypt: config.options.encrypt,
        version: PreloginPayloadVersion(
          major: int.parse(major),
          minor: int.parse(minor),
          build: int.parse(build),
          subbuild: int.parse(subbuild),
        ),
      ),
    );

    messageIo.sendMessage(PACKETTYPE['PRELOGIN']!, data: payload.data);
    debug.payload(() {
      return payload.toString(indent: '  ');
    });
  }

  sendLogin7Packet() {
    final payload = Login7Payload(
      login7Options: Login7Options(
          tdsVersion: TDSVERSIONS[config.options.tdsVersion]!,
          packetSize: config.options.packetSize,
          clientProgVer: 0,
          // clientPid: int.parse(Platform.environment['pid']!),
          connectionId: 0,
          // clientTimeZone: DateTime.now().timeZoneOffset.inMinutes,
          clientLcid: 0x00000409),
    );

    var authentication = config.authentication;
    switch (authentication.type) {
      case 'azure-active-directory-password':
        payload.fedAuth =
            FedAuth(type: 'ADAL', echo: fedAuthRequired, workflow: 'default');
        break;

      case 'azure-active-directory-access-token':
        payload.fedAuth = FedAuth(
            type: 'SECURITYTOKEN',
            echo: fedAuthRequired,
            fedAuthToken: authentication.options.token);
        break;

      case 'azure-active-directory-msi-vm':
      case 'azure-active-directory-default':
      case 'azure-active-directory-msi-app-service':
      case 'azure-active-directory-service-principal-secret':
        payload.fedAuth = FedAuth(
            type: 'ADAL', echo: fedAuthRequired, workflow: 'integrated');
        break;

      case 'ntlm':
        payload.sspi = createNTLMRequest(
          NTLMrequestOption(
            domain: authentication.options.domain,
          ),
        );
        break;

      default:
        payload.userName = authentication.options.userName;
        payload.password = authentication.options.password;
    }

    payload.hostname = config.options.workstationId ?? Platform.localHostname;
    payload.serverName =
        routingData == null ? routingData!.server : config.server;
    payload.appName = config.options.appName ?? 'Tedious';
    payload.libraryName = LIBRARYNAME;
    payload.language = config.options.language;
    payload.database = config.options.database;
    payload.clientId = Buffer.from([1, 2, 3, 4, 5, 6]);

    payload.readOnlyIntent = config.options.readOnlyIntent;
    payload.initDbFatal = !config.options.fallbackToDefaultDb;

    routingData = null;
    messageIo.sendMessage(PACKETTYPE['LOGIN7']!, data: payload.toBuffer());

    debug.payload(() {
      return payload.toString(indent: '  ');
    });
  }

  sendFedAuthTokenMessage(String token) {
    final accessTokenLen = Buffer.byteLength(token, 'ucs2');
    final data = Buffer.alloc(8 + accessTokenLen);
    var offset = 0;
    offset = data.writeUInt32LE(accessTokenLen + 4, offset);
    offset = data.writeUInt32LE(accessTokenLen, offset);
    data.write(token, offset: offset, length: 0, encoding: 'ucs2');
    messageIo.sendMessage(PACKETTYPE['FEDAUTH_TOKEN']!, data: data);
    // sent the fedAuth token message, the rest is similar to standard login 7
    //TODO:
    transitionTo(STATE['SENT_LOGIN7_WITH_STANDARD_LOGIN']!);
  }

  sendInitialSql() async {
    final payload = SqlBatchPayload(
      sqlText: getInitialSql(),
      txnDescriptor: currentTransactionDescriptor(),
      tdsVersion: config.options.tdsVersion,
    );

    final message = Message(
      type: PACKETTYPE['SQL_BATCH']!,
      resetConnection: false,
    );
    messageIo.outgoingMessageStream!.write(message, 'usc-2', (([error]) {}));
    //TODO* Readable.from(payload).pipe(message);
    final _controller = StreamController.broadcast();
    // _controller.addStream(payload);
    _controller.add(message);
  }

  getInitialSql() {
    List options = [];

    if (config.options.enableAnsiNull == true) {
      options.add('set ansi_nulls on');
    } else if (config.options.enableAnsiNull == false) {
      options.add('set ansi_nulls off');
    }

    if (config.options.enableAnsiNullDefault == true) {
      options.add('set ansi_null_dflt_on on');
    } else if (config.options.enableAnsiNullDefault == false) {
      options.add('set ansi_null_dflt_on off');
    }

    if (config.options.enableAnsiPadding == true) {
      options.add('set ansi_padding on');
    } else if (config.options.enableAnsiPadding == false) {
      options.add('set ansi_padding off');
    }

    if (config.options.enableAnsiWarnings == true) {
      options.add('set ansi_warnings on');
    } else if (config.options.enableAnsiWarnings == false) {
      options.add('set ansi_warnings off');
    }

    if (config.options.enableArithAbort == true) {
      options.add('set arithabort on');
    } else if (config.options.enableArithAbort == false) {
      options.add('set arithabort off');
    }

    if (config.options.enableConcatNullYieldsNull == true) {
      options.add('set concat_null_yields_null on');
    } else if (config.options.enableConcatNullYieldsNull == false) {
      options.add('set concat_null_yields_null off');
    }

    if (config.options.enableCursorCloseOnCommit == true) {
      options.add('set cursor_close_on_commit on');
    } else if (config.options.enableCursorCloseOnCommit == false) {
      options.add('set cursor_close_on_commit off');
    }

    if (config.options.datefirst != null) {
      options.add('set datefirst ${config.options.datefirst}');
    }

    if (config.options.dateFormat != null) {
      options.add('set dateformat ${config.options.dateFormat}');
    }

    if (config.options.enableImplicitTransactions == true) {
      options.add('set implicit_transactions on');
    } else if (config.options.enableImplicitTransactions == false) {
      options.add('set implicit_transactions off');
    }

    if (config.options.language != null) {
      options.add('set language ${config.options.language}');
    }

    if (config.options.enableNumericRoundabort == true) {
      options.add('set numeric_roundabort on');
    } else if (config.options.enableNumericRoundabort == false) {
      options.add('set numeric_roundabort off');
    }

    if (config.options.enableQuotedIdentifier == true) {
      options.add('set quoted_identifier on');
    } else if (config.options.enableQuotedIdentifier == false) {
      options.add('set quoted_identifier off');
    }

    if (config.options.textsize != null) {
      options.add('set textsize ${config.options.textsize}');
    }

    if (config.options.connectionIsolationLevel != null) {
      options.add(
          'set transaction isolation level ${getIsolationLevelText(config.options.connectionIsolationLevel)}');
    }

    if (config.options.abortTransactionOnError == true) {
      options.add('set xact_abort on');
    } else if (config.options.abortTransactionOnError == false) {
      options.add('set xact_abort off');
    }

    return options.join('\n');
  }

  processedInitialSql() {
    clearConnectTimer();
    emit('connect');
  }

  execSqlBatch(Request request) {
    makeRequest(
        request,
        PACKETTYPE['SQL_BATCH']!,
        SqlBatchPayload(
          sqlText: request.sqlTextOrProcedure!,
          txnDescriptor: currentTransactionDescriptor(),
          tdsVersion: config.options.tdsVersion,
        ));
  }

  execSql(Request request) {
    try {
      request.validateParameters(databaseCollation);
    } catch (error) {
      request.error = RequestError(message: error.toString());

      scheduleMicrotask(() {
        debug.log(error.toString());
        request.callback(MTypeError(error.toString()));
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

    makeRequest(
        request,
        PACKETTYPE['RPC_REQUEST']!,
        RpcRequestPayload(
          procedure: 'sp_executesql',
          parameters: parameters,
          txnDescriptor: currentTransactionDescriptor(),
          options: config.options,
          collation: databaseCollation,
        ));
  }

  BulkLoad newBulkLoad(String table, BulkLoadOptions options,
      [BulkLoadCallback? callback]) {
    if (options is! BulkLoadOptions) {
      throw MTypeError('"options" argument must be an object');
    }
    return BulkLoad(
      table: table,
      collation: databaseCollation,
      options: config.options,
      bulkOptions: options,
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
        callback: ([error, rowCount, rows]) {
          bulkLoad.once('cancel', (_) {
            onCancel();
          });

          if (error != null) {
            if (error.toString() == 'UNKNOWN') {
              error = MTypeError(
                  ' This is likely because the schema of the BulkLoad does not match the schema of the table you are attempting to insert into.');
            }
            bulkLoad.error = error;
            bulkLoad.callback == null ? () {} : bulkLoad.callback!(error, 0);
            return;
          }

          makeRequest(bulkLoad, PACKETTYPE['BULK_LOAD']!, payload.toIterable());
        });

    bulkLoad.once('cancel', (_) {
      onCancel();
    });

    execSqlBatch(request);
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

    makeRequest(
      request,
      PACKETTYPE['RPC_REQUEST']!,
      RpcRequestPayload(
        procedure: 'sp_prepare',
        parameters: parameters,
        txnDescriptor: currentTransactionDescriptor(),
        options: config.options,
        collation: databaseCollation,
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

    makeRequest(
      request,
      PACKETTYPE['RPC_REQUEST']!,
      RpcRequestPayload(
        procedure: 'sp_unprepare',
        parameters: parameters,
        txnDescriptor: currentTransactionDescriptor(),
        options: config.options,
        collation: databaseCollation,
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
              databaseCollation));
      }
    } catch (error) {
      request.error = RequestError(message: error.toString());

      scheduleMicrotask(() {
        debug.log(error.toString());
        request.callback(MTypeError(error.toString()));
      });

      return;
    }

    makeRequest(
        request,
        PACKETTYPE['RPC_REQUEST']!,
        RpcRequestPayload(
          procedure: 'sp_execute',
          parameters: executeParameters,
          txnDescriptor: currentTransactionDescriptor(),
          options: config.options,
          collation: databaseCollation,
        ));
  }

  callProcedure(Request request) {
    try {
      request.validateParameters(databaseCollation);
    } catch (error) {
      request.error = RequestError(message: error.toString());

      scheduleMicrotask(() {
        debug.log(error.toString());
        request.callback(
          MTypeError(error.toString()),
        );
      });

      return;
    }

    makeRequest(
        request,
        PACKETTYPE['RPC_REQUEST']!,
        RpcRequestPayload(
            procedure: request.sqlTextOrProcedure!,
            parameters: request.parameters,
            txnDescriptor: currentTransactionDescriptor(),
            options: config.options,
            collation: databaseCollation));
  }

  beginTransaction(
      {required BeginTransactionCallback callback,
      String name = '',
      int? isolationLevel}) {
    isolationLevel = config.options.isolationLevel;
    assertValidIsolationLevel(isolationLevel, 'isolationLevel');

    final transaction = Transaction(name: name, isolationLevel: isolationLevel);

    if (TDSVERSIONS[config.options.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return execSqlBatch(Request(
          sqlTextOrProcedure:
              'SET TRANSACTION ISOLATION LEVEL ${transaction.isolationLevelToTSQL()};BEGIN TRAN ${transaction.name}',
          callback: ([error, rowCount, rows]) {
            transactionDepth++;
            if (transactionDepth == 1) {
              inTransaction = true;
            }
            callback(err: error);
          }));
    }

    final request = Request(
        sqlTextOrProcedure: null,
        callback: ([error, rowCount, rows]) {
          return callback(
            err: error,
            transactionDescriptor: currentTransactionDescriptor(),
          );
        });
    return makeRequest(request, PACKETTYPE['TRANSACTION_MANAGER']!,
        transaction.beginPayload(currentTransactionDescriptor()));
  }

  commitTransaction({
    required CommitTransactionCallback callback,
    String name = '',
  }) {
    final transaction = Transaction(name: name);
    if (TDSVERSIONS[config.options.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return execSqlBatch(Request(
          sqlTextOrProcedure: 'COMMIT TRAN ${transaction.name}',
          callback: ([error, rowCount, rows]) {
            transactionDepth--;
            if (transactionDepth == 0) {
              inTransaction = false;
            }

            callback(err: error);
          }));
    }

    //TODO
    // ignore:argument_type_not_assignable

    // final fns = ;
    final request =
        Request(sqlTextOrProcedure: '', callback: Function.apply(callback, []));
    return makeRequest(request, PACKETTYPE['TRANSACTION_MANAGER']!,
        transaction.commitPayload(currentTransactionDescriptor()));
  }

  rollbackTransaction({
    required RollbackTransactionCallback callback,
    String name = '',
  }) {
    var transaction = Transaction(name: name);
    if (TDSVERSIONS[config.options.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return execSqlBatch(
        Request(
          sqlTextOrProcedure: 'ROLLBACK TRAN ${transaction.name}',
          callback: ([error, rowCount, rows]) {
            transactionDepth--;
            if (transactionDepth == 0) {
              inTransaction = false;
            }
            callback(err: error);
          },
        ),
      );
    }

    //TODO
    var request =
        Request(sqlTextOrProcedure: '', callback: Function.apply(callback, []));
    return makeRequest(request, PACKETTYPE['TRANSACTION_MANAGER']!,
        transaction.rollbackPayload(currentTransactionDescriptor()));
  }

  saveTransaction(SaveTransactionCallback? callback, String name) {
    var transaction = Transaction(name: name);
    if (TDSVERSIONS[config.options.tdsVersion]! < TDSVERSIONS['7_2']!) {
      return execSqlBatch(
        Request(
          sqlTextOrProcedure: 'SAVE TRAN ${transaction.name}',
          callback: ([error, rowCount, rows]) {
            transactionDepth++;
            callback!(err: error);
          },
        ),
      );
    }
    //TODO
    //ignore:argument_type_not_assignable

    var request = Request(
        sqlTextOrProcedure: null, callback: Function.apply(callback!, []));
    return makeRequest(
      request,
      PACKETTYPE['TRANSACTION_MANAGER']!,
      transaction.savePayload(currentTransactionDescriptor()),
    );
  }

  transaction(
    void Function({
      Error? error,
      TransactionDoneCallback? txDone,
      List<CallbackParameters>? args,
    })? cb,
    int? isolationLevel,
  ) {
    if (cb is! Function) {
      throw MTypeError('cb must be a function');
    }

    var useSavepoint = inTransaction;

    var name = '_tedious_${(RandomBytes.gen(10, isString: true))}';

    //function def inside a fns
    void txDone({
      Error? err,
      TransactionDoneCallback? done,
      List<CallbackParameters>? args,
    }) {
      if (err != null) {
        if (inTransaction && state == STATE['LOGGED_IN']) {
          rollbackTransaction(
            callback: ({err}) {
              done!(err: err, args: args);
            },
            name: name,
          );
        } else {
          done!(err: err, args: args);
        }
      } else if (useSavepoint) {
        if (TDSVERSIONS[config.options.tdsVersion]! < TDSVERSIONS['7_2']!) {
          transactionDepth--;
        }
        done!(err: null, args: args);
      } else {
        commitTransaction(
          callback: ({err}) {
            done!(err: err, args: args);
          },
          name: name,
        );
      }
    }
    //end of fns declaration

    if (useSavepoint) {
      return saveTransaction(({err}) {
        if (err != null) {
          return cb!(error: err);
        }

        if (isolationLevel != null) {
          execSqlBatch(
            Request(
              sqlTextOrProcedure:
                  'SET transaction isolation level ${getIsolationLevelText(isolationLevel)}',
              callback: ([error, rowCount, rows]) {
                //TODO
                //ignore:argument_type_not_assignable

                // return cb!(error: err, txDone: txDone);
              },
            ),
          );
        } else {
          //TODO
          //ignore:argument_type_not_assignable

          // return cb!(error: null, txDone: txDone);
        }
      }, name);
    } else {
      return beginTransaction(
          callback: ({err, transactionDescriptor}) {
            if (err != null) {
              return cb!(error: err);
            }

            //TODO
            //ignore:argument_type_not_assignable

            // return cb!(error: null, txDone: txDone);
          },
          name: name,
          isolationLevel: isolationLevel);
    }
  }

  //TODO: check & double check for better implementation

  @PrivateExposed('Used in get_parameter_encryption_metadata.dart')
  @DynamicParameterType('request', 'Request || BulkLoad')
  makeRequest(dynamic request, num packetType, Iterable<Buffer> payload,
      {String Function(String indent)? toString}) async {
    if (state != STATE['LOGGED_IN']) {
      final message =
          'Requests can only be made in the ${STATE['LOGGED_IN']!.name} state, not the ${state?.name} state';
      debug.log(message);
      request.callback(RequestError(message: message, code: 'EINVALIDSTATE'));
    } else if (request.canceled) {
      scheduleMicrotask(() {
        request.callback(RequestError(message: 'Canceled.', code: 'ECANCEL'));
      }) as RequestCompletionCallback;
    } else {
      if (packetType == PACKETTYPE['SQL_BATCH']) {
        isSqlBatch = true;
      } else {
        isSqlBatch = false;
      }

      var message = Message(
        type: packetType as int,
        resetConnection: resetConnectionOnNextRequest!,
      );
      //TODO: better message implementation
      //TODO: redo message & IO implementation

      StreamController<Buffer> payloadStreamController = StreamController();
      // payloadStreamController.addStream(payload);
      // StreamSubscription<Buffer> payloadStream = payload.listen((event) {});

      this.request = request;
      request.connection = this;
      request.rowCount = 0;
      request.rows = [];
      request.rst = [];

      onCancel() {
        payloadStreamController.stream
            .drain(message); //payloadStream.unpipe(message);
        // payloadStream.cancel();
        // payloadStream.onError((e) {
        //   throw RequestError(message: 'Canceled.', code: 'ECANCEL');
        // });

        // set the ignore bit and end the message.
        message.ignore = true;
        message.subscription.cancel();

        if (request is Request && request.paused) {
          // resume the request if it was paused so we can read the remaining tokens
          request.resume();
        }
      }

      (request as Request).once('cancel', onCancel());

      createRequestTimer();

      messageIo.outgoingMessageStream!.write(message, 'utf-8', ([error]) {});
      transitionTo(STATE['SENT_CLIENT_REQUEST']!);

      message.subscription.onDone(() {
        request.removeEventListener(
            EventListener('cancel', (val) {}, onCancel: onCancel));
        request.once('cancel', Function.apply(cancelAfterRequestSent, []));

        resetConnectionOnNextRequest = false;
        debug.payload(() {
          return payload.toString();
        });
      });

      // payloadStream.onError((error) {
      //   payloadStreamController.stream.drain(message);

      //   // Only set a request error if no error was set yet.
      //   request.error ??= error;

      //   message.ignore = true;
      //   message.subscription.cancel();
      // });
      payloadStreamController.stream.drain(message);
    }
  }

  ///* Cancel currently executed Request | BulkLoad.
  bool cancel() {
    if (request == null) {
      return false;
    }
    if (request.canceled) {
      return false;
    }
    request.cancel();
    return true;
  }

  /// Reset the connection to its initial state.
  /// Can be useful for connection pool implementations.
  void reset(ResetCallback callback) {
    var request = Request(
        sqlTextOrProcedure: getInitialSql(),
        callback: ([error, rowCount, rows]) {
          if (TDSVERSIONS[config.options.tdsVersion]! < TDSVERSIONS['7_2']!) {
            inTransaction = false;
          }
          callback(err: error);
        });
    resetConnectionOnNextRequest = true;
    execSqlBatch(request);
  }

  @PrivateExposed()
  Buffer currentTransactionDescriptor() {
    return transactionDescriptors[transactionDescriptors.length - 1];
  }

  @Private()
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
