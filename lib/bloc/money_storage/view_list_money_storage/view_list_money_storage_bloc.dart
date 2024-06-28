import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/un_view_list_money_storage_state.dart';

class ViewListMoneyStorageBloc extends IBloc<ViewListMoneyStorageBloc> {
  ViewListMoneyStorageBloc()
      : super(const UnViewListMoneyStorageState(version: 0));
}
