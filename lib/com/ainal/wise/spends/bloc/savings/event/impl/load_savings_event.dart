import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/in_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/un_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

class LoadSavingsEvent extends SavingsEvent {
  final bool isError;
  @override
  String toString() => 'LoadSavingsEvent';

  LoadSavingsEvent(this.isError);

  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    // yield const UnSavingsState(0);
    // await Future.delayed(const Duration(seconds: 1));
    savingsManager.test(isError);
    yield const InSavingsState(0, 'Hello world');
  }
}
