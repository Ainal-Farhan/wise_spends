import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/savings/state/in_saving_transaction_form_state.dart';
import 'package:wise_spends/bloc/impl/savings/state/loading_savings_state.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class LoadSavingTransactionEvent extends IEvent<SavingsBloc> {
  final String savingId;
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  LoadSavingTransactionEvent({required this.savingId});

  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(version: 0);
    yield InSavingTransactionFormState(
      version: 0,
      saving: (await _savingsManager.getSavingById(savingId))!,
    );
  }
}
