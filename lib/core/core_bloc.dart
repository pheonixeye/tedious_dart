import 'package:bloc/bloc.dart';
import 'package:tedious_dart/conn_events.dart';
import 'package:tedious_dart/conn_state.dart';
import 'package:tedious_dart/connection.dart';
import 'package:tedious_dart/core/core_events.dart';
import 'package:tedious_dart/core/core_states.dart';
import 'package:tedious_dart/models/logger_stacktrace.dart';

class CoreBloc extends Bloc<CoreEvent, CoreState> {
  final Connection connection;

  CoreBloc(this.connection) : super(InitialCoreState()) {
    on<Initialize>((event, emit) {
      emit(InitialCoreState());
      connection.add(InitialEvent());
    });

    on<Connect>((event, emit) {
      emit(CoreConnectingState());
      connection.add(EnterConnectingEvent());
    });

    on<SentPreLoginMessage>((event, emit) {
      // if (connection.state == InitialConnState()) {
      // }
      connection.on<EnterConnectingEvent>(
        (event, emit2) {
          emit(CoreSentPreLoginMessageState());
          connection.add(SentPreLoginMessageEvent());
        },
      );
    });
  }
  @override
  void onTransition(Transition<CoreEvent, CoreState> transition) {
    console.log([
      'core',
      "Event : ${transition.event}",
      "Current: ${transition.currentState}",
      "Next: ${transition.nextState}"
    ]);
    super.onTransition(transition);
  }
}
