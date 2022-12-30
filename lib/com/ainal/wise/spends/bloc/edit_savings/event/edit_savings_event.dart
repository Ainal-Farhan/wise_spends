import 'dart:async';

import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';

@immutable
abstract class EditSavingsEvent {
  Stream<EditSavingsState> applyAsync(
      {EditSavingsState currentState, EditSavingsBloc bloc});
}
