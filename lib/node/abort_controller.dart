import 'dart:mirrors';
import 'package:events_emitter/events_emitter.dart';

class AbortOptions {
  bool? capture;
  bool? once;
  bool? passive;

  AbortOptions({
    this.capture,
    this.once,
    this.passive,
  });
}

class AbortSignal<T> {
  late final EventEmitter eventEmitter;
  late bool aborted;
  dynamic onAbort;
  AbortSignal() {
    eventEmitter = EventEmitter();
    aborted = false;
    onAbort = null;
  }

  removeEventListener(String? name, dynamic Function(dynamic) handler) {
    eventEmitter.removeEventListener(EventListener(name, handler));
  }

  addEventListener<T>(String? name, dynamic Function(T) handler,
      {AbortOptions? options}) {
    eventEmitter.on(name, handler);
  }

  dispatchEvent(String type) {
    final event = Event(type, this);

    final handlerName = 'on$type';

    //TODO:

    //! if (this[handlerName] is Function) this[handlerName](event);
    InstanceMirror im = reflect(this);
    print(im.type.simpleName);
    try {
      im.invoke(Symbol(handlerName), [event]);
    } catch (e) {
      rethrow;
    }
    // mirror.invoke(#bar, []).reflectee;
    eventEmitter.emit(type, event);
  }

  @override
  String toString() => 'Instance of AbortSignal';
}

class AbortController {
  late final AbortSignal signal;

  AbortController() : signal = AbortSignal();

  void abort() {
    if (signal.aborted) return;

    signal.aborted = true;
    signal.dispatchEvent("abort");
  }

  @override
  toString() {
    return "Instance of AbortController";
  }
}
