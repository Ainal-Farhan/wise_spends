import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class ErrorLoginState extends IState<ErrorLoginState> {
  final String errorMessage;

  const ErrorLoginState({
    required super.version,
    required this.errorMessage,
  });

  @override
  String toString() => 'ErrorLoginState';

  @override
  List<Object> get props => [errorMessage];

  String get message => errorMessage;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  ErrorLoginState getNewVersion() =>
      ErrorLoginState(version: version + 1, errorMessage: errorMessage);

  @override
  ErrorLoginState getStateCopy() =>
      ErrorLoginState(version: version, errorMessage: errorMessage);
}
