import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:magic_buffer_copy/magic_buffer.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';
import 'package:tedious_dart/packet.dart';

part 'ev.dart';
part 'st.dart';

class Translator extends Bloc<TranslatorEvent, TranslatorState> {
  Packet? _packet;
  Translator() : super(const EmptyTranslator()) {
    on<TranslateEvent>((event, emit) {
      // ignore: no_leading_underscores_for_local_identifiers
      final Uint8List? _data = event.data;
      if (_data != null) {
        emit(const InTranslation());
        final buffer = Buffer(_data);
        _packet = Packet(buffer);
        emit(DataTranslation(_packet!));
      } else {
        _packet = null;
        emit(EmptyTranslator());
      }
    });

    on<FlushEvent>((event, emit) {
      _packet = null;
      emit(EmptyTranslator());
    });
  }
  @override
  void onTransition(Transition<TranslatorEvent, TranslatorState> transition) {
    console.log([
      transition.event,
      "current: ",
      transition.currentState,
      "next: ",
      transition.nextState
    ]);
    super.onTransition(transition);
  }
}
