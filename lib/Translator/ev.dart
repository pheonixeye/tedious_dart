part of "package:tedious_dart/Translator/translator.dart";

abstract class TranslatorEvent {
  const TranslatorEvent();
}

class TranslateEvent extends TranslatorEvent {
  const TranslateEvent(this.data) : super();
  final Uint8List? data;
}

class FlushEvent extends TranslatorEvent {
  const FlushEvent() : super();
}
