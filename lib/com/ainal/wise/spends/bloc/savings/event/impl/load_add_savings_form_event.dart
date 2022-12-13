import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/in_load_add_saving_form_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/loading_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/add_saving_form_vo.dart';

class LoadAddSavingsFormEvent extends SavingsEvent {
  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(0);
    yield InLoadAddSavingFormState(
        version: 0, addSavingFormVO: AddSavingFormVO());
  }
}