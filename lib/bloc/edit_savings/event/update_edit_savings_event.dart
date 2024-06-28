import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/state/done_edit_savings_state.dart';
import 'package:wise_spends/bloc/edit_savings/state/un_edit_savings_state.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/util/singleton_util.dart';
import 'package:wise_spends/vo/impl/saving/edit_saving_form_vo.dart';

class UpdateEditSavingsEvent with IEvent<EditSavingsBloc> {
  final EditSavingFormVO _editSavingFormVO;
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  UpdateEditSavingsEvent(this._editSavingFormVO);

  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, EditSavingsBloc? bloc}) async* {
    yield const UnEditSavingsState(version: 0);
    await _savingsManager.updateSaving(editSavingFormVO: _editSavingFormVO);
    yield const DoneEditSavingsState(
      nextScreenRoute: AppRouter.savingsPageRoute,
      message: 'Successfully Update Savings',
    );
  }
}
