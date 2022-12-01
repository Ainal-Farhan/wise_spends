import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

class UnLoadListSavingsState extends SavingsState {
  const UnLoadListSavingsState(int version) : super(version);

  @override
  Widget build(BuildContext context, VoidCallback load) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  SavingsState getNewVersion() {
    return UnLoadListSavingsState(version + 1);
  }

  @override
  SavingsState getStateCopy() {
    return UnLoadListSavingsState(version);
  }
}
