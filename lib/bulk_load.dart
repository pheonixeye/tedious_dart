// ignore_for_file: constant_identifier_names, unnecessary_null_comparison

import 'dart:async';

import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/conn_config_internal.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/meta/annotations.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/tracking_buffer/writable_tracking_buffer.dart';
import 'package:tedious_dart/tds_versions.dart';
import 'package:tedious_dart/token/token.dart';
import 'extensions/subscript_on_iterable.dart';

const Map<String, int> FLAGS = {
  'nullable': 1 << 0,
  'caseSen': 1 << 1,
  'updateableReadWrite': 1 << 2,
  'updateableUnknown': 1 << 3,
  'identity': 1 << 4,
  'computed': 1 << 5, // introduced in TDS 7.2
  'fixedLenCLRType': 1 << 8, // introduced in TDS 7.2
  'sparseColumnSet': 1 << 10, // introduced in TDS 7.3.B
  'hidden': 1 << 13, // introduced in TDS 7.2
  'key': 1 << 14, // introduced in TDS 7.2
  'nullableUnknown': 1 << 15 // introduced in TDS 7.2
};

const Map<String, int> DONE_STATUS = {
  'FINAL': 0x00,
  'MORE': 0x1,
  'ERROR': 0x2,
  'INXACT': 0x4,
  'COUNT': 0x10,
  'ATTN': 0x20,
  'SRVERROR': 0x100
};

typedef Order = Map<String, String>; //*{colName : ASC | DESC}

class _BulkLoadInternalOptions {
  final bool checkConstraints;
  final bool fireTriggers;
  final bool keepNulls;
  final bool lockTable;
  final Order order;

  const _BulkLoadInternalOptions({
    this.checkConstraints = false,
    this.fireTriggers = false,
    this.keepNulls = false,
    this.lockTable = false,
    this.order = const {},
  });
}

class BulkLoadOptions extends _BulkLoadInternalOptions {
  BulkLoadOptions({
    super.checkConstraints,
    super.fireTriggers,
    super.keepNulls,
    super.lockTable,
    super.order,
  });
}

typedef BulkLoadCallback = void Function([Error? err, num? rowCount]);

class Column extends Parameter {
  String objName;
  Collation? collation;

  Column(
      {required this.objName,
      this.collation,
      super.cryptoMetadata,
      super.encryptedVal,
      super.forceEncrypt,
      super.length,
      super.name,
      super.nullable,
      super.output,
      super.precision,
      super.scale,
      super.type,
      super.value})
      : super();
}

class ColumnOptions {
  bool? output;
  num? length;
  num? precision;
  num? scale;
  String? objName;
  bool? nullable;

  ColumnOptions({
    this.length,
    this.nullable,
    this.objName,
    this.output,
    this.precision,
    this.scale,
  });
}

final rowTokenBuffer = Buffer.from([TOKEN_TYPE['ROW']!]);

final textPointerAndTimestampBuffer = Buffer.from([
  0x10,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00
]);

final textPointerNullBuffer = Buffer.from([0x00]);

//TODO!
class RowTransform<T> extends Stream {
  bool columnMetadataWritten = false;
  final BulkLoad bulkLoad;
  late InternalConnectionOptions mainOptions;
  late List<Column> columns;
  final StreamController controller = StreamController();

  RowTransform({
    required this.bulkLoad,
  })  : mainOptions = bulkLoad.options,
        columns = bulkLoad.columns {
    controller.addStream(this);
  }

  @override
  StreamSubscription listen(void Function(dynamic event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }

  @DynamicParameterType('row', 'List<dynamic> | Map<String,dynamic>')
  void _transform(
    dynamic row,
    String? _encoding,
    void Function([Error? error])? callback,
  ) {
    if (!columnMetadataWritten) {
      controller.add(bulkLoad.getColMetaData());
      columnMetadataWritten = true;
    }
    controller.add(rowTokenBuffer);

    for (int i = 0; i < columns.length; i++) {
      var c = columns[i];
      dynamic value = row is List ? row[i] : row[c.objName];

      if (!bulkLoad.firstRowWritten) {
        try {
          value = c.type!.validate(value, c.collation);
        } catch (error) {
          return callback!(MTypeError(error.toString()));
        }
      }

      final parameter = Parameter(
          length: c.length,
          scale: c.scale,
          precision: c.precision,
          value: value);

      if (c.type!.name == 'Text' ||
          c.type!.name == 'Image' ||
          c.type!.name == 'NText') {
        if (value == null) {
          controller.add(textPointerNullBuffer);
          continue;
        }

        controller.add(textPointerAndTimestampBuffer);
      }

      controller.add(c.type!.generateParameterLength(
          ParameterData(value: parameter), mainOptions));

      c.type!
          .generateParameterData(ParameterData(value: parameter), mainOptions)
          .forEach((element) {
        controller.add(element);
      });
      scheduleMicrotask(() {
        callback!();
      });
    }
  }

  _flush(void Function() callback) {
    controller.add(bulkLoad.createDoneToken());
    scheduleMicrotask(callback);
  }
}

class BulkLoad extends EventEmitter {
  Error? error;
  bool canceled = false;
  bool executionStarted = false;
  bool streamingMode = false;
  String table;
  num? timeout;
  InternalConnectionOptions options;
  BulkLoadCallback? callback;
  List<Column> columns = [];
  Map<String, Column> columnsByName = {};
  bool firstRowWritten = false;
  late RowTransform<Buffer> rowToPacketTransform;
  BulkLoadOptions bulkOptions;
  Connection? connection;
  List<dynamic>? rows;
  List<dynamic>? rst;
  num? rowCount;
  Collation? collation;

  BulkLoad({
    required this.table,
    required this.collation,
    required this.options,
    required this.bulkOptions,
    required this.callback,
  }) {
    for (int i = 0; i < bulkOptions.order.length; i++) {
      if (bulkOptions.order.values[i] != 'ASC' ||
          bulkOptions.order.values[i] != 'DESC') {
        throw MTypeError(
            'The value of the "${bulkOptions.order.values[i]}" key in the "options.order" object must be either "ASC" or "DESC".');
      }
    }

    rowToPacketTransform = RowTransform(bulkLoad: this);
  }
  //TODO* end of constructor
  ///
  /// @param name The name of the column.
  /// @param type One of the supported `data types`.
  /// @param __namedParameters Additional column type information. At a minimum, `nullable` must be set to true or false.
  /// @param length For VarChar, NVarChar, VarBinary. Use length as `Infinity` for VarChar(max), NVarChar(max) and VarBinary(max).
  /// @param nullable Indicates whether the column accepts NULL values.
  /// @param objName If the name of the column is different from the name of the property found on `rowObj` arguments passed to [[addRow]] or [[Connection.execBulkLoad]], then you can use this option to specify the property name.
  /// @param precision For Numeric, Decimal.
  /// @param scale For Numeric, Decimal, Time, DateTime2, DateTimeOffset.
  ///

  addColumn(String name, DataType type, {ColumnOptions? columnOptions}) {
    columnOptions = ColumnOptions(
      output: false,
      nullable: false,
      objName: name,
    );
    if (firstRowWritten) {
      throw MTypeError(
          'Columns cannot be added to bulk insert after the first row has been written.');
    }
    if (executionStarted) {
      throw MTypeError(
          'Columns cannot be added to bulk insert after execution has started.');
    }

    final column = Column(
      type: type,
      name: name,
      value: null,
      output: columnOptions.output,
      length: columnOptions.length as int?,
      precision: columnOptions.precision,
      scale: columnOptions.scale,
      objName: columnOptions.objName!,
      nullable: columnOptions.nullable,
      collation: collation,
    );

    if ((type.id & 0x30) == 0x20) {
      if (column.length == null && type.resolveLength != null) {
        column.length = type.resolveLength(column);
      }
    }

    if (type.resolvePrecision != null && column.precision == null) {
      column.precision = type.resolvePrecision(column);
    }

    if (type.resolveScale != null && column.scale == null) {
      column.scale = type.resolveScale(column);
    }

    columns.add(column);

    columnsByName[name] = column;
  }

  getOptionsSql() {
    List addOptions = [];

    if (bulkOptions.checkConstraints == true) {
      addOptions.add('CHECK_CONSTRAINTS');
    }

    if (bulkOptions.fireTriggers == true) {
      addOptions.add('FIRE_TRIGGERS');
    }

    if (bulkOptions.keepNulls == true) {
      addOptions.add('KEEP_NULLS');
    }

    if (bulkOptions.lockTable == true) {
      addOptions.add('TABLOCK');
    }

    if (bulkOptions.order != null && bulkOptions.order.isNotEmpty) {
      List orderColumns = [];
      for (int i = 0; i < bulkOptions.order.length; i++) {
        orderColumns
            .add('${bulkOptions.order.keys[i]} ${bulkOptions.order.values[i]}');
      }

      if (orderColumns.isNotEmpty) {
        addOptions.add('ORDER (${orderColumns.join(', ')})');
      }
    }

    if (addOptions.isNotEmpty) {
      return ' WITH (${addOptions.join(',')})';
    } else {
      return '';
    }
  }

  getBulkInsertSql() {
    var sql = 'insert bulk ${table}(';
    for (int i = 0, len = columns.length; i < len; i++) {
      var c = columns[i];
      if (i != 0) {
        sql += ', ';
      }
      sql += '[${c.name}] ${c.type!.declaration(c)}';
    }
    sql += ')';

    sql += getOptionsSql();
    return sql;
  }

  getTableCreationSql() {
    var sql = 'CREATE TABLE $table(\n';
    for (int i = 0, len = columns.length; i < len; i++) {
      var c = columns[i];
      if (i != 0) {
        sql += ',\n';
      }
      sql += '[${c.name}] ${c.type!.declaration(c)}';
      if (c.nullable != null) {
        sql += ' ${c.nullable! ? 'NULL' : 'NOT NULL'}';
      }
    }
    sql += '\n)';
    return sql;
  }

  getColMetaData() {
    final tBuf = WritableTrackingBuffer(
      initialSize: 100,
      encoding: '',
      doubleSizeGrowth: true,
    );
    // TokenType
    tBuf.writeUInt8(TOKEN_TYPE['COLMETADATA']!);
    // Count
    tBuf.writeUInt16LE(columns.length);

    for (int j = 0, len = columns.length; j < len; j++) {
      var c = columns[j];
      // UserType
      if (TDSVERSIONS[options.tdsVersion]! < TDSVERSIONS['7_2']!) {
        tBuf.writeUInt16LE(0);
      } else {
        tBuf.writeUInt32LE(0);
      }

      // Flags
      var flags = FLAGS['updateableReadWrite']!;
      if (c.nullable == true) {
        flags |= FLAGS['nullable']!;
      } else if (c.nullable == null &&
          TDSVERSIONS[options.tdsVersion]! >= TDSVERSIONS['7_2']!) {
        flags |= FLAGS['nullableUnknown']!;
      }
      tBuf.writeUInt16LE(flags);

      // TYPE_INFO
      tBuf.writeBuffer(
          c.type!.generateTypeInfo(ParameterData(value: c), options));

      // TableName
      if (c.type!.hasTableName == true) {
        tBuf.writeUsVarchar(table, 'ucs2');
      }

      // ColName
      tBuf.writeBVarchar(c.name!, 'ucs2');
    }
    return tBuf.data;
  }

  setTimeout(num? timeout) {
    this.timeout = timeout;
  }

  createDoneToken() {
    // It might be nice to make DoneToken a class if anything needs to create them, but for now, just do it here
    final tBuf = WritableTrackingBuffer(
        initialSize:
            TDSVERSIONS[options.tdsVersion]! < TDSVERSIONS['7_2']! ? 9 : 13);
    tBuf.writeUInt8(TOKEN_TYPE['DONE']!);
    final status = DONE_STATUS['FINAL']!;
    tBuf.writeUInt16LE(status);
    tBuf.writeUInt16LE(0); // CurCmd (TDS ignores this)
    tBuf.writeUInt32LE(0); // row count - doesn't really matter
    if (TDSVERSIONS[options.tdsVersion]! >= TDSVERSIONS['7_2']!) {
      tBuf.writeUInt32LE(0); // row count is 64 bits in >= TDS 7.2
    }
    return tBuf.data;
  }

  cancel() {
    if (canceled) {
      return;
    }
    canceled = true;
    emit('cancel');
  }
}
