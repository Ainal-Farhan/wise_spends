import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class UnViewListMoneyStorageState extends IState<UnViewListMoneyStorageState> {
  const UnViewListMoneyStorageState({required super.version});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  UnViewListMoneyStorageState getNewVersion() =>
      UnViewListMoneyStorageState(version: version + 1);

  @override
  UnViewListMoneyStorageState getStateCopy() =>
      UnViewListMoneyStorageState(version: version);
}
