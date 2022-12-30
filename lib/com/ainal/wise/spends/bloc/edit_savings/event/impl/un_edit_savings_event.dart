import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/un_edit_savings_state.dart';

class UnEditSavingsEvent extends EditSavingsEvent {
  @override
  Stream<EditSavingsState> applyAsync(
      {EditSavingsState? currentState, EditSavingsBloc? bloc}) async* {
    yield const UnEditSavingsState(version: 0);
  }
}
