import 'dart:async';
import 'dart:io';

import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/node/abort_controller.dart';

Future<Socket> connectInParallel(
  Map<String, dynamic> options,
  AbortSignal signal,
) async {
  print(LoggerStackTrace.from(StackTrace.current).toString());

  if (signal.aborted) {
    throw AbortError();
  }
  final addresses = await lookupAllAddresses(
    options['host']!,
    signal,
  );

  return Future<Socket>(
    () async {
      List<Socket> sockets = []..length = addresses.length;
      // List<Error> errors = [];
      late Socket _s;
      for (int i = 0, len = addresses.length; i < len; i++) {
        final socket = sockets[i] = await Socket.connect(
          addresses[i].address,
          options['port']!,
        );
        _s = socket;
      }
      return _s;
    },
  );
}

Future<Socket?> connectInSequence(
  Map<String, dynamic> options,
  AbortSignal signal,
) async {
  Socket? socket;
  print(LoggerStackTrace.from(StackTrace.current).toString());

  if (signal.aborted) {
    throw AbortError();
  }
  Future<List<InternetAddress>> addresses = lookupAllAddresses(
    options['host']!,
    signal,
  );
  for (InternetAddress address in await addresses) {
    console.log([...await addresses]);
    try {
      socket = await Socket.connect(
        address.address,
        options['port']!,
      );
      return socket;
    } catch (e) {
      throw AbortError();
    }
  }

  return socket;
}

Future<List<InternetAddress>> lookupAllAddresses(
  String host,
  AbortSignal signal,
) {
  print(LoggerStackTrace.from(StackTrace.current).toString());

  if (signal.aborted) {
    throw AbortError();
  }

  if (InternetAddress.tryParse(host) != null) {
    console.log(["tryParse(host)", InternetAddress.tryParse(host)]);
    return Future.value([InternetAddress.tryParse(host)!]);
  } else {
    Future<List<InternetAddress>> adresses;
    try {
      adresses = InternetAddress.lookup(host);
      return adresses;
    } catch (e) {
      rethrow;
    }
  }
  //TODO: check future / promise implementation
}
