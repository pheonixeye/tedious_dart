import 'dart:async';
import 'dart:io';

import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/node/abort_controller.dart';

Future<Socket> connectInParallel(
  Map<String, dynamic> options,
  // LookupFunction lookup,
  AbortSignal signal,
) async {
  if (signal.aborted) {
    throw AbortError();
  }
  final addresses = await lookupAllAddresses(
    options['host']!,
    // lookup,
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

Future<Socket> connectInSequence(
  Map<String, dynamic> options,
  // LookupFunction lookup,
  AbortSignal signal,
) async {
  if (signal.aborted) {
    throw AbortError();
  }
  List<InternetAddress> addresses = await lookupAllAddresses(
    options['host']!,
    // lookup,
    signal,
  );
  late Socket _s;
  for (InternetAddress address in addresses) {
    try {
      final socket = await Socket.connect(
        address.address,
        options['port']!,
      );
      _s = socket;
      return Future.value(socket);
    } catch (e) {
      throw AbortError();
    }
  }
  return Future.value(_s);
}

Future<List<InternetAddress>> lookupAllAddresses(
  String host,
  // LookupFunction lookup,
  AbortSignal signal,
) async {
  if (signal.aborted) {
    throw AbortError();
  }

  if (InternetAddress.tryParse(host) != null) {
    return [InternetAddress.tryParse(host)!];
  } else {
    List<InternetAddress> adresses = [];
    try {
      adresses = await InternetAddress.lookup(host);
      return adresses;
    } catch (e) {
      rethrow;
    }
  }
  //TODO: check future / promise implementation
}
