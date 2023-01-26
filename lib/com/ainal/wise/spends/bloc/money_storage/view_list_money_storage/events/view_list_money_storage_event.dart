import 'dart:async';

import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';

abstract class ViewListMoneyStorageEvent {
  Stream<ViewListMoneyStorageState> applyAsync(
      {ViewListMoneyStorageState currentState, ViewListMoneyStorageBloc bloc});
}
