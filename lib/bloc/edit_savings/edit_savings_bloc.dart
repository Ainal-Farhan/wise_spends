import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/edit_savings/event/edit_savings_event.dart';
import 'package:wise_spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/bloc/edit_savings/state/impl/error_edit_savings_state.dart';
import 'package:wise_spends/bloc/edit_savings/state/impl/un_edit_savings_state.dart';

class EditSavingsBloc extends Bloc<EditSavingsEvent, EditSavingsState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct
  static final EditSavingsBloc _editSavingsBlocSingleton =
      EditSavingsBloc._internal();
  factory EditSavingsBloc() {
    return _editSavingsBlocSingleton;
  }

  EditSavingsBloc._internal() : super(const UnEditSavingsState(version: 0)) {
    on<EditSavingsEvent>((event, emit) {
      return emit.forEach<EditSavingsState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'EditSavingsBloc', error: error, stackTrace: stackTrace);
          return ErrorEditSavingsState(0, error.toString());
        },
      );
    });
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }

  EditSavingsState get initialState => const UnEditSavingsState(version: 0);
}
