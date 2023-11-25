abstract class TdsSocketEvent {
  const TdsSocketEvent();
}

class InitEvent extends TdsSocketEvent {
  const InitEvent() : super();
}

class ConnectEvent extends TdsSocketEvent {
  const ConnectEvent() : super();
}

class WriteEvent extends TdsSocketEvent {
  const WriteEvent(this.data) : super();
  final List<int> data;
}

class ReadEvent extends TdsSocketEvent {
  const ReadEvent(this.length) : super();
  final int length;
}
