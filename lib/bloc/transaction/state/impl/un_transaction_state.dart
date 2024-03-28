import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/transaction/state/transaction_state.dart';

/// UnInitialized
class UnTransactionState extends TransactionState {
  const UnTransactionState(int version) : super(version);

  @override
  String toString() => 'UnTransactionState';

  @override
  UnTransactionState getStateCopy() {
    return const UnTransactionState(0);
  }

  @override
  UnTransactionState getNewVersion() {
    return UnTransactionState(version + 1);
  }

  @override
  Widget build(BuildContext context, VoidCallback load) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
