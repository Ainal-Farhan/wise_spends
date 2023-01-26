import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';

class UnEditMoneyStorageState extends EditMoneyStorageState {
  const UnEditMoneyStorageState({required int version})
      : super(version: version);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  EditMoneyStorageState getNewVersion() =>
      UnEditMoneyStorageState(version: version + 1);

  @override
  EditMoneyStorageState getStateCopy() =>
      UnEditMoneyStorageState(version: version);
}
