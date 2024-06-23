import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/display_add_money_storage_form_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/un_add_money_storage_state.dart';

class InLoadAddMoneyStorageEvent extends IEvent<AddMoneyStorageBloc> {
  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    AddMoneyStorageBloc? bloc,
  }) async* {
    yield const UnAddMoneyStorageState(version: 0);
    yield const DisplayAddMoneyStorageFormState(version: 0);
  }
}
