class TimeoutError extends Error {
  String code;

  TimeoutError(this.code) {
    code = 'TIMEOUT_ERR';
  }

  @override
  String toString() {
    return 'The operation was aborted due to timeout';
  }
}
