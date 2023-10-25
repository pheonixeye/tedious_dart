abstract class ConnectionEvent {
  const ConnectionEvent();
}

class InitialConnectionEvent extends ConnectionEvent {
  const InitialConnectionEvent() : super();
}

class EnterConnectEvent extends ConnectionEvent {
  const EnterConnectEvent() : super();
}

class SocketErrorConnectEvent extends ConnectionEvent {
  const SocketErrorConnectEvent() : super();
}

class ConnectionTimeoutConnectEvent extends ConnectionEvent {
  const ConnectionTimeoutConnectEvent() : super();
}
