import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/money_storage/state/success_process_view_list_money_storage_state.dart';
import 'package:wise_spends/bloc/impl/money_storage/state/un_view_list_money_storage_state.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

class OnDeleteViewListMoneyStorageEvent extends IEvent<MoneyStorageBloc> {
  
  final ISavingManager _savingManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();
      
  final String selectedMoneyStorageId;

  OnDeleteViewListMoneyStorageEvent(this.selectedMoneyStorageId);

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    MoneyStorageBloc? bloc,
  }) async* {
    yield const UnViewListMoneyStorageState(version: 0);
    await _savingManager.deleteSelectedMoneyStorage(selectedMoneyStorageId);
    yield const SuccessProcessViewListMoneyStorageState(
      version: 0,
      message: 'Successfully Delete Selected Money Storage',
    );
  }
}
