class ConnectionError extends Error {
  String? code;
  bool? isTransient;

  ConnectionError(
    String message,
    this.code,
  );
}

class RequestError extends Error {
  String? code;
  int? number;
  int? state;
  int? Class;
  String? serverName;
  String? procName;
  int? lineNumber;

  RequestError(
    this.code,
    String message,
  );
}

class MTypeError extends TypeError {
  final String message;

  MTypeError(this.message);

  @override
  String toString() {
    return message;
  }
}
