import 'dart:developer' as developer;

import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/error_edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/in_edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/impl/un_edit_savings_state.dart';

class LoadEditSavingsEvent extends EditSavingsEvent {
  final bool isError;
  @override
  String toString() => 'LoadEditSavingsEvent';

  LoadEditSavingsEvent(this.isError);

  @override
  Stream<EditSavingsState> applyAsync(
      {EditSavingsState? currentState, EditSavingsBloc? bloc}) async* {
    try {
      yield const UnEditSavingsState(version: 0);
      await Future.delayed(const Duration(seconds: 1));
      yield const InEditSavingsState(0, 'Hello world');
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadEditSavingsEvent', error: _, stackTrace: stackTrace);
      yield ErrorEditSavingsState(0, _.toString());
    }
  }
}
