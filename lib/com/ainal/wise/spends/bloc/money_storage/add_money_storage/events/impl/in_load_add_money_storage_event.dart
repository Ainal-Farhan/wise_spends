import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/events/add_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/state/impl/display_add_money_storage_form_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/state/impl/un_add_money_storage_state.dart';

class InLoadAddMoneyStorageEvent extends AddMoneyStorageEvent {
  @override
  Stream<AddMoneyStorageState> applyAsync({
    AddMoneyStorageState? currentState,
    AddMoneyStorageBloc? bloc,
  }) async* {
    yield const UnAddMoneyStorageState(version: 0);
    yield const DisplayAddMoneyStorageFormState(version: 0);
  }
}
