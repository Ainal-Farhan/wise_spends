import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/savings/state/in_load_list_savings_state.dart';
import 'package:wise_spends/bloc/impl/savings/state/loading_savings_state.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class LoadListSavingsEvent extends IEvent<SavingsBloc> {
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(version: 0);
    yield InLoadListSavingsState(await _savingsManager.loadListSavingVOList(),
        version: 0);
  }
}
