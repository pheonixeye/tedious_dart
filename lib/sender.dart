import 'dart:async';
import 'dart:io';

import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/instance_lookup.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/node/abort_controller.dart';

void clearSockets({
  required List<Socket> sockets,
}) {
  for (var socket in sockets) {
    socket.close();
  }
  sockets.clear();
}

Future<Buffer?> sendInParallel(
  List<InternetAddress> addresses,
  num port,
  Buffer request,
  AbortSignal signal,
) async {
  print(LoggerStackTrace.from(StackTrace.current).toString());

  if (signal.aborted) {
    throw AbortError();
  }

  List<Socket> sockets = [];

  int errorCount = 0;

  late Buffer? result;

  for (int j = 0; j < addresses.length; j++) {
    var socket = await Socket.connect(addresses[j], port as int);
    sockets.add(socket);
    socket.listen((event) {
      result = Buffer.from(event);
    }, onError: (error) {
      errorCount++;
      for (var socket in sockets) {
        socket.close();
      }
      sockets.clear();
    });
    // socket.writeAll([request, 0, request.length, port, addresses[j].address]);
    socket.add(request.buffer);
  }
  return Future.value(result);
}

Future<Buffer?> sendMessage(
  String host,
  num port,
  LookupFunction lookup,
  AbortSignal signal,
  Buffer request,
) async {
  print(LoggerStackTrace.from(StackTrace.current).toString());

  if (signal.aborted) {
    throw AbortError();
  }

  List<InternetAddress> addresses = [];

  if (InternetAddress.tryParse(host) != null) {
    addresses = [
      InternetAddress.tryParse(host)!,
    ];
  } else {
    try {
      var ads = await InternetAddress.lookup(host);
      addresses = ads;
    } catch (e) {
      throw AbortError();
    }
  }
  return await sendInParallel(addresses, port, request, signal);
}
