import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class UnAddMoneyStorageState extends IState<UnAddMoneyStorageState> {
  const UnAddMoneyStorageState({required super.version});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  UnAddMoneyStorageState getNewVersion() =>
      UnAddMoneyStorageState(version: version + 1);

  @override
  UnAddMoneyStorageState getStateCopy() =>
      UnAddMoneyStorageState(version: version);
}
