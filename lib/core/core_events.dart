sealed class CoreEvent {
  const CoreEvent();
}

class Initialize extends CoreEvent {
  const Initialize() : super();
}

class Connect extends CoreEvent {
  const Connect() : super();

  initialiseConnection() {}
}
