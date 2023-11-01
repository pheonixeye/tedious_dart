sealed class CoreState {
  const CoreState();
}

class InitialState extends CoreState {
  const InitialState() : super();
}

class Connecting extends CoreState {
  const Connecting() : super();
}

class SentPreLoginMessageState extends CoreState {
  const SentPreLoginMessageState() : super();
}
