import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/events/view_list_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/impl/display_list_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/impl/un_view_list_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/money_storage_vo.dart';

class OnDeleteViewListMoneyStorageEvent extends ViewListMoneyStorageEvent {
  final String selectedMoneyStorageId;

  OnDeleteViewListMoneyStorageEvent(this.selectedMoneyStorageId);

  @override
  Stream<ViewListMoneyStorageState> applyAsync({
    ViewListMoneyStorageState? currentState,
    ViewListMoneyStorageBloc? bloc,
  }) async* {
    yield const UnViewListMoneyStorageState(version: 0);
    await savingManager.deleteSelectedSaving(selectedMoneyStorageId);

    List<MoneyStorageVO> moneyStorageVOList =
        await savingManager.getCurrentUserMoneyStorageVOList();

    yield DisplayListMoneyStorageState(
      version: 0,
      moneyStorageVOList: moneyStorageVOList,
    );
  }
}
