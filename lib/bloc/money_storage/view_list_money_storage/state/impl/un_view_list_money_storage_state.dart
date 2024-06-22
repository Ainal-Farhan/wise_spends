import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';

class UnViewListMoneyStorageState extends ViewListMoneyStorageState {
  const UnViewListMoneyStorageState({required super.version});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  ViewListMoneyStorageState getNewVersion() =>
      UnViewListMoneyStorageState(version: version + 1);

  @override
  ViewListMoneyStorageState getStateCopy() =>
      UnViewListMoneyStorageState(version: version);
}
