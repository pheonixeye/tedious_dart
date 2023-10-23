import 'dart:io';

class DuplexPair {
  final Socket? socket1;
  final SecureSocket? socket2;

  DuplexPair({
    this.socket1,
    this.socket2,
  });
}
