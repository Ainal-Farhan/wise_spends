import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/state/in_edit_savings_state.dart';
import 'package:wise_spends/bloc/edit_savings/state/un_edit_savings_state.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

class LoadEditSavingsEvent extends IEvent<EditSavingsBloc> {
  final String savingId;
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  @override
  String toString() => 'LoadEditSavingsEvent';

  LoadEditSavingsEvent(this.savingId);

  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, EditSavingsBloc? bloc}) async* {
    yield const UnEditSavingsState(version: 0);
    SvngSaving? saving = await _savingsManager.getSavingById(savingId);
    if (saving != null) {
      List<DropDownValueModel> moneyStorageDropDownValueModelList =
          await _savingsManager
              .getCurrentUserMoneyStorageDropDownValueModelList();
      yield InEditSavingsState(
          version: 0,
          saving: saving,
          moneyStorageList: moneyStorageDropDownValueModelList);
    }
  }
}
