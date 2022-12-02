import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/in_load_list_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/loading_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';

class LoadListSavingsEvent extends SavingsEvent {
  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(0);
    yield InLoadListSavingsState(
        0, await savingsManager.loadSavingWithManagersAsync());
  }
}
