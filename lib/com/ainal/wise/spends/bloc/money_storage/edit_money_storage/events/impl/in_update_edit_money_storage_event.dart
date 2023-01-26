import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/events/edit_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/impl/success_edit_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/impl/un_edit_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';

class InUpdateEditMoneyStorageEvent extends EditMoneyStorageEvent {
  final EditMoneyStorageFormVO editMoneyStorageFormVO;

  InUpdateEditMoneyStorageEvent({
    required this.editMoneyStorageFormVO,
  });

  @override
  Stream<EditMoneyStorageState> applyAsync({
    EditMoneyStorageState? currentState,
    EditMoneyStorageBloc? bloc,
  }) async* {
    yield const UnEditMoneyStorageState(version: 0);

    await savingManager.updateMoneyStorage(
      editMoneyStorageFormVO: editMoneyStorageFormVO,
    );

    yield const SuccessEditMoneyStorageState(version: 0);
  }
}
