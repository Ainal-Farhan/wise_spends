import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/home_logged_in_state.dart';

class ErrorHomeLoggedInState extends HomeLoggedInState {
  const ErrorHomeLoggedInState(int version, this.errorMessage) : super(version);

  final String errorMessage;

  @override
  String toString() => 'ErrorHomeLoggedInState';

  @override
  ErrorHomeLoggedInState getStateCopy() {
    return ErrorHomeLoggedInState(version, errorMessage);
  }

  @override
  ErrorHomeLoggedInState getNewVersion() {
    return ErrorHomeLoggedInState(version + 1, errorMessage);
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
