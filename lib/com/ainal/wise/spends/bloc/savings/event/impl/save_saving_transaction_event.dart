import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/in_load_list_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/impl/loading_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/saving_transaction_form_vo.dart';

class SaveSavingTransactionEvent extends SavingsEvent {
  final SavingTransactionFormVO savingTransactionFormVO;

  SaveSavingTransactionEvent({
    required this.savingTransactionFormVO,
  });

  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(0);

    if (savingTransactionFormVO.saving != null) {
      await super.savingsManager.updateSavingCurrentAmount(
            savingId: savingTransactionFormVO.saving?.id ?? '',
            transactionAmount: savingTransactionFormVO.transactionAmount ?? .0,
            transactionType: savingTransactionFormVO.typeOfTransaction ?? '',
          );
    }

    yield InLoadListSavingsState(
        0, await savingsManager.loadSavingWithTransactionsAsync());
  }
}
