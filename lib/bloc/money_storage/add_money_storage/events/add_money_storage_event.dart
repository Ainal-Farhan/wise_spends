import 'dart:async';

import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';

abstract class AddMoneyStorageEvent {
  Stream<AddMoneyStorageState> applyAsync(
      {AddMoneyStorageState currentState, AddMoneyStorageBloc bloc});
  final ISavingManager _savingManager = ISavingManager();

  ISavingManager get savingManager => _savingManager;
}
