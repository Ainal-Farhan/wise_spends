import 'dart:async';

import 'package:wise_spends/bloc/savings/index.dart';
import 'package:meta/meta.dart';
import 'package:wise_spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

@immutable
abstract class SavingsEvent {
  Stream<SavingsState> applyAsync(
      {SavingsState currentState, SavingsBloc bloc});
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>().getSavingManager();

  ISavingManager get savingsManager => _savingsManager;
}
