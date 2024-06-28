import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/savings/state/in_load_list_savings_state.dart';
import 'package:wise_spends/bloc/savings/state/loading_savings_state.dart';
import 'package:wise_spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';
import 'package:wise_spends/vo/impl/saving/saving_transaction_form_vo.dart';

class SaveSavingTransactionEvent extends IEvent<SavingsBloc> {
  final SavingTransactionFormVO savingTransactionFormVO;
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  SaveSavingTransactionEvent({
    required this.savingTransactionFormVO,
  });

  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(version: 0);

    if (savingTransactionFormVO.saving != null) {
      await _savingsManager.updateSavingCurrentAmount(
        savingId: savingTransactionFormVO.saving?.id ?? '',
        transactionAmount: savingTransactionFormVO.transactionAmount ?? .0,
        transactionType: savingTransactionFormVO.typeOfTransaction ?? '',
      );
    }

    yield InLoadListSavingsState(
      await _savingsManager.loadListSavingVOList(),
      version: 0,
    );
  }
}
