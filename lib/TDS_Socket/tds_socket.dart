import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:tedious_dart/TDS_Socket/ev.dart';
import 'package:tedious_dart/TDS_Socket/st.dart';
import 'package:tedious_dart/Translator/translator.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';

class TdsSocket extends Bloc<TdsSocketEvent, TdsSocketState> {
  late final RawSocket _socket;
  final Translator translator;
  TdsSocket()
      : translator = Translator(),
        super(TdsSocketNotConnected()) {
    on<ConnectEvent>((event, emit) async {
      emit(TdsSocketConnecting());
      try {
        await RawSocket.connect(event.host, event.port).then((value) {
          _socket = value;
          console.log([
            'Connected to ${_socket.remoteAddress} on port ${_socket.remotePort}'
          ]);
        });
        emit(TdsSocketConnected());
      } catch (e) {
        emit(TdsSocketError(e));
      }
    });

    on<WriteEvent>((event, emit) async {
      if (state != TdsSocketConnected()) {
        console.log(['Not Connected Yet, Retry in 500ms.']);
        await Future.delayed(Duration(milliseconds: 500));
      }
      emit(TdsSocketWriting());
      _socket.write(event.data);
      emit(TdsSocketConnected());
    });

    on<ReadEvent>((event, emit) async {
      if (state != TdsSocketConnected()) {
        console.log(['Not Connected Yet, Retry in 500ms.']);
        await Future.delayed(Duration(milliseconds: 500));
      }
      // final data = _socket.read(event.len);
      emit(TdsSocketReading(_socket.read(event.len)));
      translator.add(TranslateEvent(_socket.read(event.len)));
      emit(TdsSocketConnected());
      // translator.add(FlushEvent());
    });

    on<DisconnectEvent>((event, emit) async {
      if (state != TdsSocketConnected()) {
        console.log(['Cannot close in ${state.toString()}, Retry in 500ms.']);
        await Future.delayed(Duration(milliseconds: 500));
      }
      _socket.shutdown(SocketDirection.both);
      emit(TdsSocketNotConnected());
    });
  }

  @override
  void onTransition(Transition<TdsSocketEvent, TdsSocketState> transition) {
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
