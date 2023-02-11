import 'dart:async';

import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/node/abort_controller.dart';

withTimeout<T>(
  num timeout,
  Future<T> Function(AbortSignal timeoutSignal) func,
  AbortSignal? signal,
) async {
  final timeoutController = AbortController();
  // ignore: prefer_function_declarations_over_variables
  final dynamic abortCurrentAttempt = () {
    timeoutController.abort();
  };

  final timer = Timer(Duration(seconds: timeout as int), abortCurrentAttempt);
  signal?.addEventListener(
    'abort',
    abortCurrentAttempt,
    options: AbortOptions(
      once: true,
    ),
  );

  try {
    return await func(timeoutController.signal);
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
