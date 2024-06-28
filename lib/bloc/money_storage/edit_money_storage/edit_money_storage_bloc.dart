import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/un_edit_money_storage_state.dart';

class EditMoneyStorageBloc extends IBloc<EditMoneyStorageBloc> {
  EditMoneyStorageBloc() : super(const UnEditMoneyStorageState(version: 0));
}
