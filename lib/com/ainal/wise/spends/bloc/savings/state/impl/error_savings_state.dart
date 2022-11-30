import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

class ErrorSavingsState extends SavingsState {
  const ErrorSavingsState(int version, this.errorMessage) : super(version);

  final String errorMessage;

  @override
  String toString() => 'ErrorSavingsState';

  @override
  ErrorSavingsState getStateCopy() {
    return ErrorSavingsState(version, errorMessage);
  }

  @override
  ErrorSavingsState getNewVersion() {
    return ErrorSavingsState(version + 1, errorMessage);
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
              child: const Text('reload'),
              onPressed: load,
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<Object> get props => [version, errorMessage];
}
