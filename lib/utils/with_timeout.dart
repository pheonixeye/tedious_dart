import 'dart:async';

import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/node/abort_controller.dart';

Future<T> withTimeout<T>(
  num timeout,
  Future<T> Function(AbortSignal timeoutSignal) func,
  AbortSignal? signal,
) async {
  print(LoggerStackTrace.from(StackTrace.current).toString());

  final timeoutController = AbortController();

  dynamic abortCurrentAttempt([_]) {
    timeoutController.abort();
  }

  final timer = Timer(Duration(seconds: timeout as int), abortCurrentAttempt);
  signal?.addEventListener(
    'abort',
    abortCurrentAttempt,
    options: AbortOptions(
      once: true,
    ),
  );

  try {
    return func(timeoutController.signal);
  } catch (err) {
    if (err is Error &&
        err.toString() == 'AbortError' &&
        !(signal != null && signal.aborted)) {
      throw TimeoutError();
    }

    rethrow;
  } finally {
    signal?.removeEventListener('abort', abortCurrentAttempt);
    timer.cancel();
  }
}
