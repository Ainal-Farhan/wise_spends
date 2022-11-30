import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

/// UnInitialized
class UnSavingsState extends SavingsState {
  const UnSavingsState(int version) : super(version);

  @override
  String toString() => 'UnSavingsState';

  @override
  UnSavingsState getStateCopy() {
    return const UnSavingsState(0);
  }

  @override
  UnSavingsState getNewVersion() {
    return UnSavingsState(version + 1);
  }

  @override
  Widget build(BuildContext context, VoidCallback load) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
