import 'dart:io';

import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/debug.dart';
import 'package:tedious_dart/tedious_dart.dart';
import 'package:tedious_dart/transaction.dart';

void main() {
  final config = InternalConnectionConfig(
    server: 'localhost',
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
    authentication: AuthenticationType('default').auth,
  );
  final conn = Connection(config);
  conn.connect((error) {});
}


// config.options.requestTimeout = 30 * 1000;
// config.options.debug = {
//   data: true,
//   payload: false,
//   token: false,
//   packet: true,
//   log: true
// };

// const connection = new Connection(config);

// connection.connect(connected);
// connection.on('infoMessage', infoError);
// connection.on('errorMessage', infoError);
// connection.on('end', end);
// connection.on('debug', debug);

// function connected(err) {
//   if (err) {
//     console.log(err);
//     process.exit(1);
//   }

//   // console.log('connected');

//   process.stdin.resume();

//   process.stdin.on('data', function(chunk) {
//     exec(chunk);
//   });

//   process.stdin.on('end', function() {
//     process.exit(0);
//   });
// }

// function exec(sql) {
//   sql = sql.toString();

//   const request = new Request(sql, statementComplete);
//   request.on('columnMetadata', columnMetadata);
//   request.on('row', row);
//   request.on('done', requestDone);

//   connection.execSql(request);
// }

// function requestDone(rowCount, more) {
//   // console.log(rowCount + ' rows');
// }

// function statementComplete(err, rowCount) {
//   if (err) {
//     console.log('Statement failed: ' + err);
//   } else {
//     console.log(rowCount + ' rows');
//   }
// }

// function end() {
//   console.log('Connection closed');
//   process.exit(0);
// }

// function infoError(info) {
//   console.log(info.number + ' : ' + info.message);
// }

// function debug(message) {
//   // console.log(message);
// }

// function columnMetadata(columnsMetadata) {
//   columnsMetadata.forEach((column) => {
//     // console.log(column);
//   });
// }

// function row(columns) {
//   let values = '';
//   let value;

//   columns.forEach((column) => {
//     if (column.value === null) {
//       value = 'NULL';
//     } else {
//       value = column.value;
//     }

//     values += value + '\t';
//   });

//   console.log(values);
// }
