sealed class CoreState {
  const CoreState();
}

class InitialCoreState extends CoreState {
  const InitialCoreState() : super();
}

class CoreConnectingState extends CoreState {
  const CoreConnectingState() : super();
}

class CoreSentPreLoginMessageState extends CoreState {
  const CoreSentPreLoginMessageState() : super();
}
