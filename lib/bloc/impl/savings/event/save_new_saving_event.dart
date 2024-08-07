import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/state/loading_savings_state.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

class SaveNewSavingEvent extends IEvent<SavingsBloc> {
  final SavingVO _addSavingFormVO;
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  SaveNewSavingEvent({required SavingVO addSavingFormVO})
      : _addSavingFormVO = addSavingFormVO;

  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, SavingsBloc? bloc}) async* {
    const LoadingSavingsState(version: 0);

    try {
      await _savingsManager.addNewSaving(
          name: _addSavingFormVO.savingName!,
          initialAmount: _addSavingFormVO.currentAmount!,
          isHasGoal: _addSavingFormVO.isHasGoal!,
          goalAmount: _addSavingFormVO.goalAmount!,
          moneyStorageId: _addSavingFormVO.moneyStorageId ?? '',
          savingTableType: _addSavingFormVO.savingTableType!);
    } catch (_) {}

    bloc!.add(LoadListSavingsEvent());
  }
}
