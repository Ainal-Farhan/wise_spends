import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/state/success_edit_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/state/un_edit_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';
import 'package:wise_spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';

class InUpdateEditMoneyStorageEvent extends IEvent<MoneyStorageBloc> {
  final EditMoneyStorageFormVO editMoneyStorageFormVO;
  final ISavingManager _savingManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  InUpdateEditMoneyStorageEvent({
    required this.editMoneyStorageFormVO,
  });

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    MoneyStorageBloc? bloc,
  }) async* {
    yield const UnEditMoneyStorageState(version: 0);

    await _savingManager.updateMoneyStorage(
      editMoneyStorageFormVO: editMoneyStorageFormVO,
    );

    yield const SuccessEditMoneyStorageState(version: 0);
  }
}
