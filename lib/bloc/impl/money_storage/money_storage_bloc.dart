import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/impl/money_storage/state/un_view_list_money_storage_state.dart';

class MoneyStorageBloc extends IBloc<MoneyStorageBloc> {
  MoneyStorageBloc()
      : super(const UnViewListMoneyStorageState(version: 0));
}
