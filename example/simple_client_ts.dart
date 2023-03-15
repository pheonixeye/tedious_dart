import 'package:tedious_dart/conn_authentication.dart';
import 'package:tedious_dart/conn_config.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/request.dart';
import 'dart:developer' show log;

final config = ConnectionConfiguration(
  server: '127.0.0.1',
  options: ConnectionOptions(),
  authentication: AuthenticationType(
    type: 'default',
    options: AuthOptions(
      userName: 'sa',
      password: 'admin',
    ),
  ),
);
final conn = Connection(config);

executeStatement() {
  final request = Request(
    sqlTextOrProcedure: 'select * from MyTable',
    callback: ([_, __, ___]) {
      log('DONE!');
      conn.close();
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

void main() {
  try {
    conn.connect((error) {
      conn.on('connect', (_) {
        executeStatement();
      });
    });
  } catch (e) {
    rethrow;
  }
}
