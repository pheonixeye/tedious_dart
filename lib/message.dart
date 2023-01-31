import 'dart:async';

import 'package:node_interop/buffer.dart';

class Message extends Stream<Buffer> {
  int type;
  bool resetConnection;
  bool? ignore;

  Message({
    required this.type,
    required this.resetConnection,
    this.ignore = false,
  }) : super();

  @override
  Future<E> asFuture<E>([E? futureValue]) async {
    return await asFuture(futureValue);
  }

  @override
  Future<void> cancel() async {
    await cancel();
  }

  @override
  bool get isPaused => throw UnimplementedError();

  @override
  void onData(void Function(Buffer data)? handleData) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void onError(Function? handleError) {}

  @override
  void pause([Future<void>? resumeSignal]) {
    pause(resumeSignal);
  }

  @override
  void resume() {
    resume();
  }

  @override
  Future<bool> any(bool Function(Buffer element) test) {
    // TODO: implement any
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> asBroadcastStream(
      {void Function(StreamSubscription<Buffer> subscription)? onListen,
      void Function(StreamSubscription<Buffer> subscription)? onCancel}) {
    // TODO: implement asBroadcastStream
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Buffer event) convert) {
    // TODO: implement asyncExpand
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Buffer event) convert) {
    // TODO: implement asyncMap
    throw UnimplementedError();
  }

  @override
  Stream<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  Future<bool> contains(Object? needle) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> distinct(
      [bool Function(Buffer previous, Buffer next)? equals]) {
    // TODO: implement distinct
    throw UnimplementedError();
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    // TODO: implement drain
    throw UnimplementedError();
  }

  @override
  Future<Buffer> elementAt(int index) {
    // TODO: implement elementAt
    throw UnimplementedError();
  }

  @override
  Future<bool> every(bool Function(Buffer element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Buffer element) convert) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  // TODO: implement first
  Future<Buffer> get first => throw UnimplementedError();

  @override
  Future<Buffer> firstWhere(bool Function(Buffer element) test,
      {Buffer Function()? orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, Buffer element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Future forEach(void Function(Buffer element) action) {
    // TODO: implement forEach
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> handleError(Function onError,
      {bool Function(dynamic error)? test}) {
    // TODO: implement handleError
    throw UnimplementedError();
  }

  @override
  // TODO: implement isBroadcast
  bool get isBroadcast => throw UnimplementedError();

  @override
  // TODO: implement isEmpty
  Future<bool> get isEmpty => throw UnimplementedError();

  @override
  Future<String> join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  // TODO: implement last
  Future<Buffer> get last => throw UnimplementedError();

  @override
  Future<Buffer> lastWhere(bool Function(Buffer element) test,
      {Buffer Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  // TODO: implement length
  Future<int> get length => throw UnimplementedError();

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }

  @override
  Stream<S> map<S>(S Function(Buffer event) convert) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  Future pipe(StreamConsumer<Buffer> streamConsumer) {
    // TODO: implement pipe
    throw UnimplementedError();
  }

  @override
  Future<Buffer> reduce(
      Buffer Function(Buffer previous, Buffer element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  // TODO: implement single
  Future<Buffer> get single => throw UnimplementedError();

  @override
  Future<Buffer> singleWhere(bool Function(Buffer element) test,
      {Buffer Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> skipWhile(bool Function(Buffer element) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> takeWhile(bool Function(Buffer element) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> timeout(Duration timeLimit,
      {void Function(EventSink<Buffer> sink)? onTimeout}) {
    // TODO: implement timeout
    throw UnimplementedError();
  }

  @override
  Future<List<Buffer>> toList() {
    // TODO: implement toList
    throw UnimplementedError();
  }

  @override
  Future<Set<Buffer>> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<Buffer, S> streamTransformer) {
    // TODO: implement transform
    throw UnimplementedError();
  }

  @override
  Stream<Buffer> where(bool Function(Buffer event) test) {
    // TODO: implement where
    throw UnimplementedError();
  }
}
