import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/savings/state/error_savings_state.dart';
import 'package:wise_spends/bloc/savings/state/loading_savings_state.dart';

class SavingsBloc extends Bloc<IEvent<SavingsBloc>, IState<dynamic>> {
  static final SavingsBloc _savingsBlocSingleton = SavingsBloc._internal();
  factory SavingsBloc() {
    return _savingsBlocSingleton;
  }

  SavingsBloc._internal() : super(const LoadingSavingsState(version: 0)) {
    on<IEvent<SavingsBloc>>((event, emit) {
      return emit.forEach<IState<dynamic>>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'SavingsBloc', error: error, stackTrace: stackTrace);
          return ErrorSavingsState(error.toString(), version: 0);
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
