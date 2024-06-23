import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/success_add_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/un_add_money_storage_state.dart';
import 'package:wise_spends/constant/saving/money_storage_constant.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';
import 'package:wise_spends/vo/impl/money_storage/add_money_storage_form_vo.dart';

class InSaveAddMoneyStorageEvent extends IEvent<AddMoneyStorageBloc> {
  final AddMoneyStorageFormVO addMoneyStorageFormVO;
  
  final ISavingManager _savingManager =
      SingletonUtil.getSingleton<IManagerLocator>().getSavingManager();

  InSaveAddMoneyStorageEvent({
    required this.addMoneyStorageFormVO,
  });

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    AddMoneyStorageBloc? bloc,
  }) async* {
    yield const UnAddMoneyStorageState(version: 0);

    await _savingManager.addNewMoneyStorage(
      shortName: addMoneyStorageFormVO.shortName ?? '',
      longName: addMoneyStorageFormVO.longName ?? '',
      type: addMoneyStorageFormVO.type ??
          MoneyStorageConstant
              .moneyStorageTypeDropDownValueModelList.first.value,
    );

    yield const SuccessAddMoneyStorageState(version: 0);
  }
}
