import 'package:tedious_dart/conn_state_enum.dart';

abstract class ConnectionState {
  const ConnectionState();
}

class InitialState extends ConnectionState {
  const InitialState() : super();
  static const CSE name = CSE.INITIALIZED;
}

class Connecting extends ConnectionState {
  const Connecting() : super();
  static const CSE name = CSE.CONNECTING;

  //enter
  // //* initalize connection:
  // //* createConnectTimer =>
  // //* if(has port) connectOnPort => else => instanceLookup => connectOnPort => if(error) => clearConnectTimer
  // //* connect = multiSubnetFailover ? connectInParallel : connectInSequence;
  // //* socket => messageIo => socket(secure) => sendPreLogin => CSE(SENT_PRELOGIN)
}

class Final extends ConnectionState {
  const Final() : super();
  static const CSE name = CSE.FINAL;

  cleanUpConnection() {}
}
