import 'dart:async';

import 'package:wise_spends/bloc/savings/index.dart';
import 'package:meta/meta.dart';
import 'package:wise_spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';

@immutable
abstract class SavingsEvent {
  Stream<SavingsState> applyAsync(
      {SavingsState currentState, SavingsBloc bloc});
  final ISavingManager _savingsManager = ISavingManager();

  ISavingManager get savingsManager => _savingsManager;
}
