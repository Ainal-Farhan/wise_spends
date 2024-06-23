import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class ErrorSavingsState extends IState<ErrorSavingsState> {
  const ErrorSavingsState(this.errorMessage, {required super.version});

  final String errorMessage;

  @override
  String toString() => 'ErrorSavingsState';

  @override
  ErrorSavingsState getStateCopy() =>
      ErrorSavingsState(errorMessage, version: version);

  @override
  ErrorSavingsState getNewVersion() =>
      ErrorSavingsState(errorMessage, version: version + 1);

  @override
  Widget build(BuildContext context) {
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
