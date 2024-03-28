import 'dart:async';

import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

abstract class ViewListMoneyStorageEvent {
  Stream<ViewListMoneyStorageState> applyAsync(
      {ViewListMoneyStorageState currentState, ViewListMoneyStorageBloc bloc});
  final ISavingManager _savingManager =
      SingletonUtil.getSingleton<IManagerLocator>().getSavingManager();

  ISavingManager get savingManager => _savingManager;
}
