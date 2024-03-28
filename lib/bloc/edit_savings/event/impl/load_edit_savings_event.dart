import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/event/edit_savings_event.dart';
import 'package:wise_spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/bloc/edit_savings/state/impl/in_edit_savings_state.dart';
import 'package:wise_spends/bloc/edit_savings/state/impl/un_edit_savings_state.dart';
import 'package:wise_spends/db/app_database.dart';

class LoadEditSavingsEvent extends EditSavingsEvent {
  final String savingId;

  @override
  String toString() => 'LoadEditSavingsEvent';

  LoadEditSavingsEvent(this.savingId);

  @override
  Stream<EditSavingsState> applyAsync(
      {EditSavingsState? currentState, EditSavingsBloc? bloc}) async* {
    yield const UnEditSavingsState(version: 0);
    SvngSaving? saving = await savingsManager.getSavingById(savingId);
    if (saving != null) {
      List<DropDownValueModel> moneyStorageDropDownValueModelList =
          await savingsManager
              .getCurrentUserMoneyStorageDropDownValueModelList();
      yield InEditSavingsState(0, saving, moneyStorageDropDownValueModelList);
    }
  }
}
