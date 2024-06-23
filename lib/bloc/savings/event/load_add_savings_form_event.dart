import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/savings/state/in_load_add_saving_form_state.dart';
import 'package:wise_spends/bloc/savings/state/loading_savings_state.dart';
import 'package:wise_spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

class LoadAddSavingsFormEvent extends IEvent<SavingsBloc> {
  final ISavingManager _savingsManager =
      SingletonUtil.getSingleton<IManagerLocator>().getSavingManager();

  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(version: 0);

    List<DropDownValueModel> moneyStorages = await _savingsManager
        .getCurrentUserMoneyStorageDropDownValueModelList();

    yield InLoadAddSavingFormState(version: 0, moneyStorageList: moneyStorages);
  }
}
