part of "package:tedious_dart/Translator/translator.dart";

abstract class TranslatorState {
  const TranslatorState();
}

class EmptyTranslator extends TranslatorState {
  const EmptyTranslator() : super();
}

class InTranslation extends TranslatorState {
  const InTranslation() : super();
}

class DataTranslation extends TranslatorState {
  final Packet packet;
  DataTranslation(this.packet) : super() {
    console.log([packet.toString()]);
  }
}
