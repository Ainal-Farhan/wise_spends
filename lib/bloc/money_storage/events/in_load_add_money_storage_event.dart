import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/state/display_add_money_storage_form_state.dart';
import 'package:wise_spends/bloc/money_storage/state/un_add_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage_bloc.dart';

class InLoadAddMoneyStorageEvent extends IEvent<MoneyStorageBloc> {
  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    MoneyStorageBloc? bloc,
  }) async* {
    yield const UnAddMoneyStorageState(version: 0);
    yield const DisplayAddMoneyStorageFormState(version: 0);
  }
}
