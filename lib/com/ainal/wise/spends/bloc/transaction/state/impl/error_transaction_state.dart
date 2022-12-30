import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/transaction_state.dart';

class ErrorTransactionState extends TransactionState {
  const ErrorTransactionState(int version, this.errorMessage) : super(version);

  final String errorMessage;

  @override
  String toString() => 'ErrorSavingsState';

  @override
  ErrorTransactionState getStateCopy() {
    return ErrorTransactionState(version, errorMessage);
  }

  @override
  ErrorTransactionState getNewVersion() {
    return ErrorTransactionState(version + 1, errorMessage);
  }

  @override
  Widget build(BuildContext context, VoidCallback load) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(errorMessage),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: load,
              child: const Text('reload'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<Object> get props => [version, errorMessage];
}
