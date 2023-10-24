import 'dart:io';

import 'package:tedious_dart/conn_authentication.dart';
import 'package:tedious_dart/conn_config.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/request.dart';
import 'dart:developer' show log;

final config = ConnectionConfiguration(
  server: '127.0.0.1',
  options: ConnectionOptions(),
  authentication: AuthenticationType(
    type: AuthType.default_,
    options: AuthOptions(
      userName: 'sa',
      password: 'admin',
    ),
  ),
);
final conn = Connection(config);

executeStatement() {
  final request = Request(
    sqlTextOrProcedure: 'select * from [dbo].[abdo]',
    callback: ([_, __, ___]) {
      log('DONE!');
      conn.close();
      print('called conn.close()');
    },
  );
  request.on('row', (Iterable columns) {
    for (var column in columns) {
      if (column.value == null) {
        log('NULL');
      } else {
        log(column.value);
      }
    }
  });
  request.on('done', (rowCount) {
    log('Done is called!');
  });
  request.on('doneInProc', (rowCount) {
    log('$rowCount  rows returned');
  });
  conn.execSql(request);
}

void main() async {
  print(LoggerStackTrace.from(StackTrace.current).toString());
  try {
    conn.connect((error) {
      conn.on('connect', (_) {
        executeStatement();
      });
    });
  } catch (e) {
    rethrow;
  }
  // print(await InternetAddress.lookup('127.0.0.1'));
}
