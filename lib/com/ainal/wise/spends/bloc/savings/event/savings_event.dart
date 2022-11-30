import 'dart:async';

import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

@immutable
abstract class SavingsEvent {
  Stream<SavingsState> applyAsync(
      {SavingsState currentState, SavingsBloc bloc});
  final SavingsRepository _savingsRepository = SavingsRepository();

  SavingsRepository get savingsRepository => _savingsRepository;
}
