import 'dart:io';

class DuplexPair {
  final RawSocket? socket1;
  final RawSocket? socket2;

  DuplexPair({
    this.socket1,
    this.socket2,
  });
}
