import 'dart:async';

import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';

abstract class ViewListMoneyStorageEvent {
  Stream<ViewListMoneyStorageState> applyAsync(
      {ViewListMoneyStorageState currentState, ViewListMoneyStorageBloc bloc});
  final ISavingManager _savingManager = ISavingManager();

  ISavingManager get savingManager => _savingManager;
}
