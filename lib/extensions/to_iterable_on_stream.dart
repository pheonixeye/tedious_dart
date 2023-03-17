extension ToIterable<T> on Stream<T> {
  Iterable<T> toIterable() {
    List<T> _list = [];
    toList().then((value) => _list.addAll(value));
    return _list;
  }
}
