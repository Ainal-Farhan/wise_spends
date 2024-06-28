import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/un_add_money_storage_state.dart';

class AddMoneyStorageBloc extends IBloc<AddMoneyStorageBloc> {
  AddMoneyStorageBloc() : super(const UnAddMoneyStorageState(version: 0));
}
