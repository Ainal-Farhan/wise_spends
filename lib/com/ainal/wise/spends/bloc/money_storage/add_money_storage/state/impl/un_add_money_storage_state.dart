import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';

class UnAddMoneyStorageState extends AddMoneyStorageState {
  const UnAddMoneyStorageState({required int version})
      : super(version: version);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  AddMoneyStorageState getNewVersion() =>
      UnAddMoneyStorageState(version: version + 1);

  @override
  AddMoneyStorageState getStateCopy() =>
      UnAddMoneyStorageState(version: version);
}
