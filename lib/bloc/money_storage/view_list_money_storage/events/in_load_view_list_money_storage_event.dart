import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/display_list_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/un_view_list_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';
import 'package:wise_spends/vo/impl/money_storage/money_storage_vo.dart';

class InLoadViewListMoneyStorageEvent extends IEvent<ViewListMoneyStorageBloc> {
  final ISavingManager _savingManager =
      SingletonUtil.getSingleton<IManagerLocator>().getSavingManager();

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    ViewListMoneyStorageBloc? bloc,
  }) async* {
    yield const UnViewListMoneyStorageState(version: 0);

    List<MoneyStorageVO> moneyStorageVOList =
        await _savingManager.getCurrentUserMoneyStorageVOList();

    yield DisplayListMoneyStorageState(
        version: 0, moneyStorageVOList: moneyStorageVOList);
  }
}
