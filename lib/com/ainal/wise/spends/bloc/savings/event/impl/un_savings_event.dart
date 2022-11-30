import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/un_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

class UnSavingsEvent extends SavingsEvent {
  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    yield const UnSavingsState(0);
  }
}
