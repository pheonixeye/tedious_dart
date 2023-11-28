abstract class TdsSocketEvent {
  const TdsSocketEvent();
}

class ConnectEvent extends TdsSocketEvent {
  const ConnectEvent({
    String? host,
    int? port,
  })  : host = host ?? 'localhost',
        port = port ?? 1433,
        super();
  final String host;
  final int port;
}

class WriteEvent extends TdsSocketEvent {
  const WriteEvent(this.data) : super();
  final List<int> data;
}

class ReadEvent extends TdsSocketEvent {
  const ReadEvent({int? length})
      : _length = length,
        super();
  final int? _length;

  int? get len => _length;
}

class DisconnectEvent extends TdsSocketEvent {
  const DisconnectEvent() : super();
}
