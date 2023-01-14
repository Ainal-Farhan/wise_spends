import 'dart:async';

import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';

@immutable
abstract class EditSavingsEvent {
  final ISavingManager _savingsManager = ISavingManager();

  ISavingManager get savingsManager => _savingsManager;

  Stream<EditSavingsState> applyAsync(
      {EditSavingsState currentState, EditSavingsBloc bloc});
}
