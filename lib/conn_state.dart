import 'package:tedious_dart/conn_state_enum.dart';

abstract class ConnectionState {
  const ConnectionState();
  CSE get name;
}

class InitialConnState extends ConnectionState {
  const InitialConnState() : super();
  @override
  final CSE name = CSE.INITIALIZED;
}

class ConnConnectingState extends ConnectionState {
  const ConnConnectingState() : super();
  @override
  final CSE name = CSE.CONNECTING;

  //enter
  // //* initalize connection:
  // //* createConnectTimer =>
  // //* if(has port) connectOnPort => else => instanceLookup => connectOnPort => if(error) => clearConnectTimer
  // //* connect = multiSubnetFailover ? connectInParallel : connectInSequence;
  // //* socket => messageIo => socket(secure) => sendPreLogin => CSE(SENT_PRELOGIN)
}

class SentPreLogin extends ConnectionState {
  const SentPreLogin() : super();
  @override
  final CSE name = CSE.SENT_PRELOGIN;
}

class SentLogin7Withfedauth extends ConnectionState {
  const SentLogin7Withfedauth() : super();
  @override
  CSE get name => CSE.SENT_LOGIN7_WITH_FEDAUTH;
}

class SentLogin7WithNTLMLogin extends ConnectionState {
  const SentLogin7WithNTLMLogin() : super();
  @override
  CSE get name => CSE.SENT_LOGIN7_WITH_NTLM;
}

class SentLogin7WithStandardLogin extends ConnectionState {
  const SentLogin7WithStandardLogin() : super();
  @override
  CSE get name => CSE.SENT_LOGIN7_WITH_STANDARD_LOGIN;
}

class Final extends ConnectionState {
  const Final() : super();
  @override
  final CSE name = CSE.FINAL;
}
