import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/loading_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/add_saving_form_vo.dart';

class SaveNewSavingEvent extends SavingsEvent {
  final AddSavingFormVO _addSavingFormVO;

  SaveNewSavingEvent({required AddSavingFormVO addSavingFormVO})
      : _addSavingFormVO = addSavingFormVO;

  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    const LoadingSavingsState(0);

    try {
      await savingsManager.addNewSaving(
        name: _addSavingFormVO.savingName!,
        initialAmount: _addSavingFormVO.currentAmount!,
        isHasGoal: _addSavingFormVO.isHasGoal!,
        goalAmount: _addSavingFormVO.goalAmount!,
      );
    } catch (_) {}

    bloc!.add(LoadListSavingsEvent());
  }
}
