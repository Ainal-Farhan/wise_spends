import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/savings/state/savings_state.dart';

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
  Widget build(BuildContext context, Function load) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(errorMessage),
        ],
      ),
    );
  }

  @override
  List<Object> get props => [version, errorMessage];
}
