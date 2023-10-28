import 'dart:async';
import 'dart:io';

import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/node/abort_controller.dart';

class LocalConnectionOptions {
  final String host;
  final int port;
  final String? localAddress;

  LocalConnectionOptions({
    required this.host,
    required this.port,
    this.localAddress,
  });
}

Stream<Socket?> connectInParallel(
  LocalConnectionOptions options,
  AbortSignal signal,
) async* {
  // print(LoggerStackTrace.from(StackTrace.current).toString());

  if (signal.aborted) {
    throw AbortError();
  }
  final addresses = await lookupAllAddresses(
    options.host,
    signal,
  );

  // List<Socket> sockets = [];
  for (var adr in addresses) {
    final socket = await Socket.connect(
      adr,
      options.port,
    );
    // print(i);
    yield socket;
  }
}

Stream<Socket?> connectInSequence(
  LocalConnectionOptions options,
  AbortSignal signal,
) async* {
  Socket? socket;
  // print(LoggerStackTrace.from(StackTrace.current).toString());

  if (signal.aborted) {
    throw AbortError();
  }
  Future<List<InternetAddress>> addresses = lookupAllAddresses(
    options.host,
    signal,
  );
  for (InternetAddress address in await addresses) {
    console.log([...await addresses]);
    try {
      socket = await Socket.connect(
        address.address,
        options.port,
      );
      yield socket;
    } catch (e) {
      print(e.toString());
      throw AbortError();
    }
  }

  // return socket;
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
