import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/events/add_money_storage_event.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/impl/success_add_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/impl/un_add_money_storage_state.dart';
import 'package:wise_spends/constant/saving/money_storage_constant.dart';
import 'package:wise_spends/vo/impl/money_storage/add_money_storage_form_vo.dart';

class InSaveAddMoneyStorageEvent extends AddMoneyStorageEvent {
  final AddMoneyStorageFormVO addMoneyStorageFormVO;

  InSaveAddMoneyStorageEvent({
    required this.addMoneyStorageFormVO,
  });

  @override
  Stream<AddMoneyStorageState> applyAsync({
    AddMoneyStorageState? currentState,
    AddMoneyStorageBloc? bloc,
  }) async* {
    yield const UnAddMoneyStorageState(version: 0);

    await savingManager.addNewMoneyStorage(
      shortName: addMoneyStorageFormVO.shortName ?? '',
      longName: addMoneyStorageFormVO.longName ?? '',
      type: addMoneyStorageFormVO.type ??
          MoneyStorageConstant
              .moneyStorageTypeDropDownValueModelList.first.value,
    );

    yield const SuccessAddMoneyStorageState(version: 0);
  }
}
