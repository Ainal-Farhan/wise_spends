import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:wise_spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/bloc/savings/state/impl/in_load_add_saving_form_state.dart';
import 'package:wise_spends/bloc/savings/state/impl/loading_savings_state.dart';
import 'package:wise_spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/bloc/savings/savings_bloc.dart';

class LoadAddSavingsFormEvent extends SavingsEvent {
  @override
  Stream<SavingsState> applyAsync(
      {SavingsState? currentState, SavingsBloc? bloc}) async* {
    yield const LoadingSavingsState(0);

    List<DropDownValueModel> moneyStorages =
        await savingsManager.getCurrentUserMoneyStorageDropDownValueModelList();

    yield InLoadAddSavingFormState(version: 0, moneyStorageList: moneyStorages);
  }
}
