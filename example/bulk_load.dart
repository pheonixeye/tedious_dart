import 'package:tedious_dart/bulk_load.dart';
import 'package:tedious_dart/data_types/int.dart';
import 'package:tedious_dart/data_types/nvarchar.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/request.dart';

import 'simple_client_ts.dart';

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

const table = '[dbo].[test_bulk]';

createTable() {
  const sql =
      'CREATE TABLE ${table} ([c1] [int]  DEFAULT 58, [c2] [varchar](30))';
  final request = Request(
      sqlTextOrProcedure: sql,
      callback: ([error, rowCount, rows]) {
        if (error != null) {
          throw error;
        }

        console.log(['${table} created!']);
        loadBulkData();
      });

  conn.execSql(request);
}

// Executing Bulk Load
//--------------------------------------------------------------------------------
loadBulkData() {
  final option = BulkLoadOptions(keepNulls: true);
  // option to enable null values
  final bulkLoad = conn.newBulkLoad(table, option, ([error, rowCount]) {
    if (error != null) {
      throw error;
    }

    console.log(['rows inserted :', rowCount]);
    console.log(['DONE!']);
    conn.close();
  });

  // setup columns
  bulkLoad.addColumn('c1', DATATYPES[Int.refID]!,
      columnOptions: ColumnOptions(nullable: true));
  bulkLoad.addColumn('c2', DATATYPES[NVarChar.refID]!,
      columnOptions: ColumnOptions(length: 50, nullable: true));

  // add rows into an array
  // final transform = RowTransform(bulkLoad: bulkLoad);
  // transform.
  final rows = [
    {'c1': 1},
    {'c1': 2, 'c2': 'hello'}
  ];

  // perform bulk insert
  conn.execBulkLoad(bulkLoad, rows);
}
