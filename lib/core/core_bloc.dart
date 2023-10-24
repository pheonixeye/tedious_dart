import 'package:bloc/bloc.dart';
import 'package:tedious_dart/core/core_events.dart';
import 'package:tedious_dart/core/core_states.dart';

class CoreBloc extends Bloc<CoreEvent, CoreState> {
  CoreBloc() : super(InitialState()) {
    on<Initialize>(
      (event, emit) => emit(InitialState()),
    );
  }
}
