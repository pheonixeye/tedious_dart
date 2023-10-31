import 'package:tedious_dart/conn_state_enum.dart';

abstract class ConnectionState {
  const ConnectionState();
  CSE get name;
}

class InitialState extends ConnectionState {
  const InitialState() : super();
  @override
  final CSE name = CSE.INITIALIZED;
}

class Connecting extends ConnectionState {
  const Connecting() : super();
  @override
  final CSE name = CSE.CONNECTING;

  //enter
  // //* initalize connection:
  // //* createConnectTimer =>
  // //* if(has port) connectOnPort => else => instanceLookup => connectOnPort => if(error) => clearConnectTimer
  // //* connect = multiSubnetFailover ? connectInParallel : connectInSequence;
  // //* socket => messageIo => socket(secure) => sendPreLogin => CSE(SENT_PRELOGIN)
}

class Final extends ConnectionState {
  const Final() : super();
  @override
  final CSE name = CSE.FINAL;
}
