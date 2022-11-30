import 'dart:async';

import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/saving_manager.dart';

@immutable
abstract class SavingsEvent {
  Stream<SavingsState> applyAsync(
      {SavingsState currentState, SavingsBloc bloc});
  final ISavingManager _savingsManager = SavingManager();

  ISavingManager get savingsManager => _savingsManager;
}
