import 'dart:async';

import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

abstract class EditMoneyStorageEvent {
  Stream<EditMoneyStorageState> applyAsync(
      {EditMoneyStorageState currentState, EditMoneyStorageBloc bloc});
  final ISavingManager _savingManager =
      SingletonUtil.getSingleton<IManagerLocator>().getSavingManager();

  ISavingManager get savingManager => _savingManager;
}
