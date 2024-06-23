import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

/// UnInitialized
class UnEditSavingsState extends IState<UnEditSavingsState> {
  const UnEditSavingsState({required super.version});

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
