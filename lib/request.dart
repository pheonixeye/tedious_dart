import 'package:events_emitter/emitters/event_emitter.dart';
import 'package:tedious_dart/always_encrypted/types.dart';
import 'package:tedious_dart/collation.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/models/data_types.dart';
import 'package:tedious_dart/models/errors.dart';

typedef CompletionCallback = void Function({
  Error? error,
  num? rowCount,
  dynamic rows,
});

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

  late CompletionCallback userCallback;

  num? handle;

  Error? error;

  Connection? connection;

  num? timeout;

  List<dynamic>? rows;

  List<dynamic>? rst;

  num? rowCount;

  late CompletionCallback callback;

  bool? shouldHonorAE;

  late SQLServerStatementColumnEncryptionSetting
      statementColumnEncryptionSetting;

  late bool cryptoMetadataLoaded;

  RequestOptions? requestOptions;
  //TODO!: should not need overriding the on & emit functions in the class but
  //TODO!:implement them in the call site ?????
  Request({
    this.sqlTextOrProcedure,
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

    callback = ({Error? error, num? rowCount, dynamic rows}) {
      if (preparing) {
        preparing = false;
        if (error != null) {
          emit('error', error);
        } else {
          emit('prepared');
        }
      } else {
        userCallback(
          error: error,
          rowCount: rowCount,
          rows: rows,
        );
        emit('requestCompleted');
      }
    };

    //TODO! end of constructor
  }

  addParameter(String name, DataType type, dynamic value,
      [ParameterOptions? options]) {
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

  addOutputParameter(
      String name, DataType type, dynamic value, ParameterOptions? options) {
    addParameter(name, type, value, ParameterOptions(output: true));
  }

  makeParamsParameter(List<Parameter> parameters) {
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

  validateParameters(Collation? collation) {
    for (var i = 0, len = parameters.length; i < len; i++) {
      var parameter = parameters[i];

      try {
        parameter.value = parameter.type!.validate(parameter.value, collation);
      } catch (error) {
        throw RequestError(
          'EPARAM',
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
