import 'package:tedious_dart/conn_authentication.dart';
import 'package:tedious_dart/conn_config.dart';
import 'package:tedious_dart/conn_events.dart';
import 'package:tedious_dart/connection.dart';

void main(List<String> args) {
  // final observer = Bloc.observer;

  connection.add(InitialEvent());
}

final config = ConnectionConfiguration(
  server: '127.0.0.1',
  options: ConnectionOptions(
    port: 1433,
  ),
  authentication: AuthenticationType(
    type: AuthType.default_,
    options: AuthOptions(
      userName: 'kz',
      password: 'admin',
    ),
  ),
);

final connection = Connection(config);

// final core = CoreBloc(connection);
