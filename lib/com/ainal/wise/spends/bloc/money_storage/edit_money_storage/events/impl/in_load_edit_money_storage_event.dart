import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/events/edit_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/impl/display_edit_money_storage_form_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/impl/un_edit_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';

class InLoadEditMoneyStorageEvent extends EditMoneyStorageEvent {
  final String selectedMoneyStorageId;

  InLoadEditMoneyStorageEvent(this.selectedMoneyStorageId);

  @override
  Stream<EditMoneyStorageState> applyAsync({
    EditMoneyStorageState? currentState,
    EditMoneyStorageBloc? bloc,
  }) async* {
    yield const UnEditMoneyStorageState(version: 0);
    SvngMoneyStorage moneyStorage =
        await savingManager.getMoneyStorageById(selectedMoneyStorageId);

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
