import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/error_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/un_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct
  static final SavingsBloc _savingsBlocSingleton = SavingsBloc._internal();
  factory SavingsBloc() {
    return _savingsBlocSingleton;
  }

  SavingsBloc._internal() : super(const UnSavingsState(0)) {
    on<SavingsEvent>((event, emit) {
      return emit.forEach<SavingsState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'SavingsBloc', error: error, stackTrace: stackTrace);
          return ErrorSavingsState(0, error.toString());
        },
      );
    });
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }
}
