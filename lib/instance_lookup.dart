// ignore_for_file: finalant_identifier_names, prefer_if_null_operators, non_constant_identifier_names

import 'dart:io';

import 'package:magic_buffer/magic_buffer.dart';
import 'package:tedious_dart/models/errors.dart';
import 'package:tedious_dart/node/abort_controller.dart';
import 'package:tedious_dart/sender.dart';
import 'package:tedious_dart/utils/with_timeout.dart';

final SQL_SERVER_BROWSER_PORT = 1434;
final TIMEOUT = 2 * 1000;
final RETRIES = 3;
// There are three bytes at the start of the response, whose purpose is unknown.
final MYSTERY_HEADER_LENGTH = 3;

// typedef LookupFunction = void Function(String hostname, dynamic options,
//     void Function(Error? error, List addresses) callback);
typedef LookupFunction = Future<List<InternetAddress>> Function(String host,
    {InternetAddressType type});

class InstanceLookUpOptions {
  String? server;
  String? instanceName;
  num? timeout;
  num? retries;
  num? port;
  LookupFunction? lookup;
  AbortSignal? signal;

  InstanceLookUpOptions({
    this.instanceName,
    this.lookup,
    this.port,
    this.retries,
    this.server,
    this.signal,
    this.timeout,
  });
}

Future instanceLookup(InstanceLookUpOptions options) async {
  final server = options.server;
  if (server is! String) {
    throw MTypeError('Invalid arguments: "server" must be a string');
  }

  final instanceName = options.instanceName;
  if (instanceName is! String) {
    throw MTypeError('Invalid arguments: "instanceName" must be a string');
  }

  final timeout = options.timeout == null ? TIMEOUT : options.timeout;
  if (timeout is! num) {
    throw MTypeError('Invalid arguments: "timeout" must be a number');
  }

  final retries = options.retries == null ? RETRIES : options.retries;
  if (retries is! num) {
    throw MTypeError('Invalid arguments: "retries" must be a number');
  }

  if (options.lookup != null && options.lookup is! Function) {
    throw MTypeError('Invalid arguments: "lookup" must be a function');
  }
  final lookup = options.lookup ?? InternetAddress.lookup;
  // ?? dns.lookup; //TODO:

  if (options.port != null && options.port is! num) {
    throw MTypeError('Invalid arguments: "port" must be a number');
  }
  final port = options.port ?? SQL_SERVER_BROWSER_PORT;

  final signal = options.signal!;

  if (signal.aborted) {
    throw AbortError();
  }

  dynamic response;

  for (int i = 0; i <= retries; i++) {
    try {
      response = await withTimeout(timeout, (signal) async {
        final request = Buffer.from([0x02]);
        return await sendMessage(
          options.server!,
          port,
          //ignore:argument_type_not_assignable

          lookup,
          signal,
          request,
        );
      }, signal);
    } catch (err) {
      // If the current attempt timed out, continue with the next
      if (!signal.aborted && err is Error && err.toString() == 'TimeoutError') {
        continue;
      }

      rethrow;
    }
  }

  if (!response) {
    throw MTypeError(
        'Failed to get response from SQL Server Browser on $server');
  }

  final message = response.toString('ascii', MYSTERY_HEADER_LENGTH);
  final foundPort = parseBrowserResponse(message, instanceName);

  if (!foundPort) {
    throw MTypeError('Port for $instanceName not found in ${options.server}');
  }

  return foundPort;
}

parseBrowserResponse(String response, String instanceName) {
  dynamic getPort;

  final instances = response.split(';;');
  for (int i = 0, len = instances.length; i < len; i++) {
    final instance = instances[i];
    final parts = instance.split(';');

    for (int p = 0, partsLen = parts.length; p < partsLen; p += 2) {
      final name = parts[p];
      final value = parts[p + 1];

      if (name == 'tcp' && getPort! + null) {
        final port = int.parse(int.parse(value).toRadixString(10));
        return port;
      }

      if (name == 'InstanceName') {
        if (value.toUpperCase() == instanceName.toUpperCase()) {
          getPort = true;
        } else {
          getPort = false;
        }
      }
    }
  }
}
