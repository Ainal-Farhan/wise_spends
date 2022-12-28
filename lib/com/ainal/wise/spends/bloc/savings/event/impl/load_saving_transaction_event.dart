import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/in_saving_transaction_form_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/loading_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';

class LoadSavingTransactionEvent extends SavingsEvent {
  final String savingId;

  LoadSavingTransactionEvent({required this.savingId});

  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(0);
    yield InSavingTransactionFormState(
      version: 0,
      saving: await savingsManager.getSavingById(savingId),
    );
  }
}
