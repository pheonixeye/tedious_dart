import 'dart:async';

import 'package:events_emitter/events_emitter.dart';
import 'package:node_interop/node.dart';

class Message extends Stream<Buffer> {
  int type;
  bool resetConnection;
  bool? ignore;
  late final EventEmitter _eventEmitter;

  Message({
    required this.type,
    required this.resetConnection,
    this.ignore = false,
  }) : super() {
    _eventEmitter = EventEmitter();
  }

  final Set<EventListener> _listeners = {};

  @override
  StreamSubscription<Buffer> listen(void Function(Buffer event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }

  bool addEventListener<T>(EventListener<T> listener) {
    final added = _listeners.add(listener);
    if (added) listener.onAdd?.call(_eventEmitter);
    return added;
  }

  bool removeEventListener<T>(EventListener<T> listener) {
    final removed = _listeners.remove(listener);
    if (removed) listener.onRemove?.call(_eventEmitter);
    return removed;
  }

  bool emitEvent<T extends Event>(T event) {
    bool allSatisfied = true;
    for (final listener in _listeners.toList()) {
      final satisfied = listener.call<T>(event);
      if (!satisfied) allSatisfied = false;
    }
    return allSatisfied;
  }

  bool emit<T>(String type, [T? data]) {
    if (data == null) return emitEvent(Event(type, null));
    return emitEvent(Event<T>(type, data));
  }

  EventListener<T> on<T>(String? type, EventCallback<T> callback) {
    final listener = EventListener<T>(type, callback);
    addEventListener(listener);
    return listener;
  }

  Future<T> once<T>(String? type, [EventCallback<T>? callback]) {
    final completer = Completer<T>();
    final listener = EventListener<T>(
      type,
      (data) {
        callback?.call(data);
        completer.complete(data);
      },
      once: true,
    );
    addEventListener(listener);
    return completer.future;
  }

  EventListener<T> onAny<T>(EventCallback<T> callback) => on(null, callback);

  /// Remove an attached listener, by **event type**, **data type** and **callback**...
  bool off<T>({String? type, EventCallback<T>? callback}) {
    bool removed = false;
    for (final listener in _listeners.toList()) {
      if (listener.protected) continue;
      if (listener.matches(type, callback)) {
        removed = removeEventListener(listener) || removed;
      }
    }
    return removed;
  }
}
