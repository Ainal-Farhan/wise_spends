import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/edit_savings/state/error_edit_savings_state.dart';
import 'package:wise_spends/bloc/edit_savings/state/un_edit_savings_state.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';

class EditSavingsBloc extends Bloc<IEvent<EditSavingsBloc>, IState<dynamic>> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct
  static final EditSavingsBloc _editSavingsBlocSingleton =
      EditSavingsBloc._internal();
  factory EditSavingsBloc() {
    return _editSavingsBlocSingleton;
  }

  EditSavingsBloc._internal() : super(const UnEditSavingsState(version: 0)) {
    on<IEvent<EditSavingsBloc>>((event, emit) {
      return emit.forEach<IState<dynamic>>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'EditSavingsBloc', error: error, stackTrace: stackTrace);
          return ErrorEditSavingsState(
              version: 0, errorMessage: error.toString());
        },
      );
    });
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  IState<dynamic> get initialState => const UnEditSavingsState(version: 0);
}
