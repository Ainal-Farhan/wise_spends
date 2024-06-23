import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/display_edit_money_storage_form_state.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/un_edit_money_storage_state.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/util/singleton_util.dart';
import 'package:wise_spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';

class InLoadEditMoneyStorageEvent extends IEvent<EditMoneyStorageBloc> {
  final String selectedMoneyStorageId;

  InLoadEditMoneyStorageEvent(this.selectedMoneyStorageId);

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    EditMoneyStorageBloc? bloc,
  }) async* {
    yield const UnEditMoneyStorageState(version: 0);
    SvngMoneyStorage? moneyStorage =
        await SingletonUtil.getSingleton<IRepositoryLocator>()
            .getMoneyStorageRepository()
            .findById(id: selectedMoneyStorageId);

    if (moneyStorage != null) {
      yield DisplayEditMoneyStorageFormState(
        version: 0,
        editMoneyStorageFormVO: EditMoneyStorageFormVO(
          id: moneyStorage.id,
          shortName: moneyStorage.shortName,
          longName: moneyStorage.longName,
          type: moneyStorage.type,
        ),
      );
    }
  }
}
