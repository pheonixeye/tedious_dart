import 'package:bloc/bloc.dart';
import 'package:tedious_dart/conn_events.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/core/core_events.dart';
import 'package:tedious_dart/core/core_states.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';

class CoreBloc extends Bloc<CoreEvent, CoreState> {
  final Connection connection;

  CoreBloc(this.connection) : super(InitialState()) {
    on<Initialize>((event, emit) {
      connection.add(InitialEvent());
      emit(InitialState());
    });

    on<Connect>((event, emit) {
      connection.add(EnterConnectingEvent());
      emit(Connecting());
    });

    on<SentPreLoginMessage>((event, emit) {
      if (connection.state is Connecting) {
        connection.add(SentPreLoginMessageEvent());
        emit(SentPreLoginMessageState());
      }
    });
  }

  @override
  void onChange(Change<CoreState> change) {
    console.log(['Core', change.toString()]);
    super.onChange(change);
  }
}
