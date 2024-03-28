import 'dart:async';

import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';

abstract class EditMoneyStorageEvent {
  Stream<EditMoneyStorageState> applyAsync(
      {EditMoneyStorageState currentState, EditMoneyStorageBloc bloc});
  final ISavingManager _savingManager = ISavingManager();

  ISavingManager get savingManager => _savingManager;
}
