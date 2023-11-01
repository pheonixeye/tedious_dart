abstract class ConnectionEvent {
  const ConnectionEvent();
}

class InitialEvent extends ConnectionEvent {
  const InitialEvent() : super();
}

class EnterConnectingEvent extends ConnectionEvent {
  const EnterConnectingEvent() : super();
}

class SentPreLoginMessageEvent extends ConnectionEvent {
  const SentPreLoginMessageEvent() : super();
}

//!-------------------------------------------------------//

class SocketErrorConnectingEvent extends ConnectionEvent {
  const SocketErrorConnectingEvent() : super();
}

class ConnectionTimeoutConnectingEvent extends ConnectionEvent {
  const ConnectionTimeoutConnectingEvent() : super();
}
