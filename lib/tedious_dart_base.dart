// TODO: Put public facing types in this file.

import 'package:tedious_dart/conn_config.dart';
import 'package:tedious_dart/connection.dart';

connect(
  ConnectionConfiguration config, //TODO: modify to ConnectionConfig
  void Function(Error? error)? connectListener,
) {
  final connection = Connection(config);
  connection.connect(connectListener);
  return connection;
}
