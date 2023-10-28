import 'package:bloc/bloc.dart';
import 'package:tedious_dart/conn_authentication.dart';
import 'package:tedious_dart/conn_config.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/core/core_bloc.dart';
import 'package:tedious_dart/core/core_events.dart';

void main(List<String> args) {
  final observer = Bloc.observer;

  core.add(Initialize());
}

final config = ConnectionConfiguration(
  server: '127.0.0.1',
  options: ConnectionOptions(),
  authentication: AuthenticationType(
    type: AuthType.default_,
    options: AuthOptions(
      userName: 'kz',
      password: 'admin',
    ),
  ),
);

final connection = Connection(config);

final core = CoreBloc(connection);
