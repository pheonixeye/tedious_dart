// ignore_for_file: unnecessary_cast

class SyncAsyncIterable<T> {
  dynamic _syncAsyncIterable;
  late final Type _type;

  SyncAsyncIterable(dynamic syncOrAsyncIterable) {
    if (syncOrAsyncIterable is Iterable<T>) {
      _syncAsyncIterable = syncOrAsyncIterable as Iterable<T>;
      _type = Iterable;
    } else if (syncOrAsyncIterable is Stream<T>) {
      _syncAsyncIterable = syncOrAsyncIterable as Stream<T>;
      _type = Stream;
    } else {
      throw ArgumentError(
          'Unexpected Argument Type ${syncOrAsyncIterable.runtimeType}',
          'syncAsyncIterable');
    }
  }

  dynamic get streamOrIterable => switch (_type) {
        Stream => _syncAsyncIterable as Stream<T>,
        Iterable => _syncAsyncIterable as Iterable<T>,
        _ => throw UnimplementedError()
      };
}
