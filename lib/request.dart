import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';

typedef RequestCompletionCallback = void Function([
  Error? error,
  num? rowCount,
  dynamic rows,
]);

class ParameterOptions {
  bool? output;
  num? length;
  num? precision;
  num? scale;

  ParameterOptions({
    this.length,
    this.output,
    this.precision,
    this.scale,
  });
}

class RequestOptions {
  SQLServerStatementColumnEncryptionSetting? statementColumnEncryptionSetting;
  RequestOptions({this.statementColumnEncryptionSetting});
}

class Request extends EventEmitter {
  String? sqlTextOrProcedure;

  late List<Parameter> parameters;

  late Map<String, Parameter> parametersByName;

  late bool preparing;

  late bool canceled;

  late bool paused;

  late RequestCompletionCallback? userCallback;

  num? handle;

  RequestError? error;

  Connection? connection;

  num? timeout;

  List<dynamic>? rows;

  List<dynamic>? rst;

  num? rowCount;

  RequestCompletionCallback callback = ([error, rowCount, rows]) {};

  bool? shouldHonorAE;

  late SQLServerStatementColumnEncryptionSetting
      statementColumnEncryptionSetting;

  late bool cryptoMetadataLoaded;

  RequestOptions? requestOptions;
  //TODO!: should not need overriding the on & emit functions in the class but
  //TODO!:implement them in the call site ?????
  Request({
    required this.sqlTextOrProcedure,
    required this.callback,
    this.requestOptions,
  }) {
    sqlTextOrProcedure = sqlTextOrProcedure;
    parameters = [];
    parametersByName = {};
    preparing = false;
    handle = null;
    canceled = false;
    paused = false;
    error = null;
    connection = null;
    timeout = null;
    userCallback = callback;
    statementColumnEncryptionSetting = (requestOptions != null
        ? requestOptions!.statementColumnEncryptionSetting!
        : SQLServerStatementColumnEncryptionSetting.UseConnectionSetting);
    cryptoMetadataLoaded = false;

    callback = ([Error? error, num? rowCount, dynamic rows]) {
      if (preparing) {
        preparing = false;
        if (error != null) {
          emit('error', error);
        } else {
          emit('prepared');
        }
      } else {
        userCallback!(
          error,
          rowCount,
          rows,
        );
        emit('requestCompleted');
      }
    };

    //TODO! end of constructor
  }

  void setRowCount(num value) {
    rowCount = value;
  }

  void addParameter(String name, DataType type, dynamic value,
      [ParameterOptions? options]) {
    print(LoggerStackTrace.from(StackTrace.current).toString());

    Parameter parameter = Parameter(
        type: type,
        name: name,
        value: value,
        output: options!.output,
        length: options.length! as int,
        precision: options.precision,
        scale: options.scale);

    parameters.add(parameter);
    parametersByName[name] = parameter;
  }

  void addOutputParameter(
      String name, DataType type, dynamic value, ParameterOptions? options) {
    print(LoggerStackTrace.from(StackTrace.current).toString());

    addParameter(name, type, value, ParameterOptions(output: true));
  }

  String makeParamsParameter(List<Parameter> parameters) {
    print(LoggerStackTrace.from(StackTrace.current).toString());

    var paramsParameter = '';
    for (var i = 0, len = parameters.length; i < len; i++) {
      var parameter = parameters[i];
      if (paramsParameter.isNotEmpty) {
        paramsParameter += ', ';
      }
      paramsParameter += '@${parameter.name} ';
      paramsParameter += parameter.type!.declaration(parameter);
      if (parameter.output != null) {
        paramsParameter += ' OUTPUT';
      }
    }
    return paramsParameter;
  }

  void validateParameters(Collation? collation) {
    print(LoggerStackTrace.from(StackTrace.current).toString());

    for (var i = 0, len = parameters.length; i < len; i++) {
      var parameter = parameters[i];

      try {
        parameter.value = parameter.type!.validate(parameter.value, collation);
      } catch (error) {
        throw RequestError(
          code: 'EPARAM',
          message:
              'Validation failed for parameter \'${parameter.name}\'. $error',
        );
      }
    }
  }

  pause() {
    if (paused) {
      return;
    }
    emit('pause');
    paused = true;
  }

  resume() {
    if (!paused) {
      return;
    }
    paused = false;
    emit('resume');
  }

  cancel() {
    if (canceled) {
      return;
    }
    canceled = true;
    emit('cancel');
  }

  setTimeout(num timeout) {
    this.timeout = timeout;
  }
}
