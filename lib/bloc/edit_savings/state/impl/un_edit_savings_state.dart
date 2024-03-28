import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/edit_savings/state/edit_savings_state.dart';

/// UnInitialized
class UnEditSavingsState extends EditSavingsState {
  const UnEditSavingsState({required int version})
      : super(
          version: version,
        );

  @override
  String toString() => 'UnEditSavingsState';

  @override
  UnEditSavingsState getStateCopy() {
    return const UnEditSavingsState(
      version: 0,
    );
  }

  @override
  UnEditSavingsState getNewVersion() {
    return UnEditSavingsState(version: version + 1);
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
