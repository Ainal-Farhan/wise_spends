import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/event/load_edit_savings_event.dart';
import 'package:wise_spends/bloc/i_state.dart';

class ErrorEditSavingsState extends IState<ErrorEditSavingsState> {
  const ErrorEditSavingsState({super.version = 0, this.errorMessage = ''});

  final String errorMessage;

  @override
  String toString() => 'ErrorEditSavingsState';

  @override
  ErrorEditSavingsState getStateCopy() =>
      ErrorEditSavingsState(version: version, errorMessage: errorMessage);

  @override
  ErrorEditSavingsState getNewVersion() =>
      ErrorEditSavingsState(version: version + 1, errorMessage: errorMessage);

  @override
  List<Object> get props => [version, errorMessage];

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => EditSavingsBloc().add(LoadEditSavingsEvent('')),
            child: const Text('reload'),
          ),
        ),
      ],
    ));
  }
}
