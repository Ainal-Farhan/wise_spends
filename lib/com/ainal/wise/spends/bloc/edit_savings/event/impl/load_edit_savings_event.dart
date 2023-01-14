import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/in_edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/un_edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';

class LoadEditSavingsEvent extends EditSavingsEvent {
  final String savingId;

  @override
  String toString() => 'LoadEditSavingsEvent';

  LoadEditSavingsEvent(this.savingId);

  @override
  Stream<EditSavingsState> applyAsync(
      {EditSavingsState? currentState, EditSavingsBloc? bloc}) async* {
    yield const UnEditSavingsState(version: 0);
    SvngSaving saving = await savingsManager.getSavingById(savingId);
    yield InEditSavingsState(0, saving);
  }
}
