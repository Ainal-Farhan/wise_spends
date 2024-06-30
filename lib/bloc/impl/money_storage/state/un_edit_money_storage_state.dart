import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class UnEditMoneyStorageState extends IState<UnEditMoneyStorageState> {
  const UnEditMoneyStorageState({required super.version});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  UnEditMoneyStorageState getNewVersion() =>
      UnEditMoneyStorageState(version: version + 1);

  @override
  UnEditMoneyStorageState getStateCopy() =>
      UnEditMoneyStorageState(version: version);
}
