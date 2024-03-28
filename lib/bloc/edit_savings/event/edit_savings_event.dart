import 'dart:async';

import 'package:meta/meta.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

@immutable
abstract class EditSavingsEvent {
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>().getSavingManager();

  ISavingManager get savingsManager => _savingsManager;

  Stream<EditSavingsState> applyAsync(
      {EditSavingsState currentState, EditSavingsBloc bloc});
}
