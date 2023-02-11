// ignore_for_file: non_constant_identifier_names

class ConnectionError extends Error {
  String? code;
  bool? isTransient;

  ConnectionError(
    String message, [
    this.code,
  ]);
}

class RequestError extends Error {
  late String? code;
  late String? message;

  int? number;
  int? state;
  int? Class;
  String? serverName;
  String? procName;
  int? lineNumber;

  RequestError({
    this.message,
    this.code,
    int? number,
    int? state,
    int? Class,
    String? serverName,
    String? procName,
    int? lineNumber,
  }) {
    code = 'ECANCEL';
    message = 'Canceled';
  }
}

class MTypeError extends TypeError {
  final String message;

  MTypeError(this.message);

  @override
  String toString() {
    return message;
  }
}

class ErrorWithCode extends MTypeError {
  final String code;
  ErrorWithCode(this.code) : super(code);
}

class TimeoutError extends Error {
  late String? code;
  late String? name;

  TimeoutError({this.code, this.name}) {
    code = 'TIMEOUT_ERR';
    name = 'AbortError';
  }

  @override
  String toString() {
    return 'The operation was aborted due to timeout';
  }
}

class AbortError extends Error {
  late String? code;
  late String? name;

  AbortError({this.code, this.name}) : super() {
    code = 'ABORT_ERR';
    name = 'AbortError';
  }

  @override
  String toString() {
    return 'The operation was aborted';
  }
}
