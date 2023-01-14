import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/done_edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/un_edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/edit_saving_form_vo.dart';

class UpdateEditSavingsEvent with EditSavingsEvent {
  final EditSavingFormVO _editSavingFormVO;

  UpdateEditSavingsEvent(this._editSavingFormVO);

  @override
  Stream<EditSavingsState> applyAsync(
      {EditSavingsState? currentState, EditSavingsBloc? bloc}) async* {
    yield const UnEditSavingsState(version: 0);
    await savingsManager.updateSaving(editSavingFormVO: _editSavingFormVO);
    yield const DoneEditSavingsState(
      nextScreenRoute: AppRouter.savingsPageRoute,
      message: 'Successfully Update Savings',
    );
  }
}
