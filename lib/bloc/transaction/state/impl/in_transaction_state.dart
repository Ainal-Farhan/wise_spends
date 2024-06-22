import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/transaction/state/transaction_state.dart';

/// Initialized
class InTransactionState extends TransactionState {
  const InTransactionState(super.version, this.hello);

  final String hello;

  @override
  String toString() => 'InTransactionState $hello';

  @override
  InTransactionState getStateCopy() {
    return InTransactionState(version, hello);
  }

  @override
  InTransactionState getNewVersion() {
    return InTransactionState(version + 1, hello);
  }

  @override
  List<Object> get props => [version, hello];

  @override
  Widget build(BuildContext context, Function load) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(hello),
          const Text('Flutter files: done'),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('throw error'),
              onPressed: () => load(true),
            ),
          ),
        ],
      ),
    );
  }
}
