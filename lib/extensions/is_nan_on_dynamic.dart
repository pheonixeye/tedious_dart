extension IsNaN on dynamic {
  bool get isNaN {
    return (this is num || this is int || this is double) ? false : true;
  }
}
