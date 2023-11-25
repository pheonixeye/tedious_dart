import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:tedious_dart/TDS_Socket/ev.dart';
import 'package:tedious_dart/TDS_Socket/st.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';

class TdsSocket extends Bloc<TdsSocketEvent, TdsSocketState> {
  final Future<RawSocket> _socket;
  late final RawSocket socket;
  TdsSocket({TdsSocketConnecting initialState = const TdsSocketConnecting()})
      : _socket = RawSocket.connect(
          initialState.host,
          initialState.port,
        ),
        super(initialState) {
    on<TdsSocketEvent>((event, emit) async {
      emit(TdsSocketConnecting());
      while (state == TdsSocketConnecting()) {
        console.log(['Not Connected Yet, Retry in 500ms.']);
        await Future.delayed(Duration(milliseconds: 500));
        emit(TdsSocketConnecting());
      }
    });

    on<InitEvent>((event, emit) async {
      try {
        emit(TdsSocketConnecting());
        await _init().whenComplete(() {
          console.log([
            "Connected to ${socket.remoteAddress} on Port ${socket.remotePort}"
          ]);
        });
        emit(TdsSocketConnected());
      } catch (e) {
        emit(TdsSocketError(e));
      }
    });

    on<WriteEvent>((event, emit) async {
      while (state == TdsSocketConnecting()) {
        console.log(['Not Connected Yet, Retry in 500ms.']);
        await Future.delayed(Duration(milliseconds: 500));
        emit(TdsSocketConnecting());
      }
      socket.write(event.data);
      emit(TdsSocketWriting());
    });

    on<ReadEvent>((event, emit) async {
      while (state == TdsSocketConnecting()) {
        console.log(['Not Connected Yet, Retry in 500ms.']);
        await Future.delayed(Duration(milliseconds: 500));
        emit(TdsSocketConnecting());
      }
      socket.read(event.length);
      emit(TdsSocketReading());
    });
  }

  Future<void> _init() async {
    socket = await _socket;
  }
}
