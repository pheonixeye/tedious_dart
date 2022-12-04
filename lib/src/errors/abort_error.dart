class AbortError extends Error {
  String code;

  AbortError(this.code) {
    code = 'ABORT_ERR';
  }

  @override
  String toString() {
    return 'The operation was aborted';
  }
}
