import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/impl/load_edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';

class ErrorEditSavingsState extends EditSavingsState {
  const ErrorEditSavingsState(int version, this.errorMessage)
      : super(
          version: version,
        );

  final String errorMessage;

  @override
  String toString() => 'ErrorEditSavingsState';

  @override
  ErrorEditSavingsState getStateCopy() {
    return ErrorEditSavingsState(version, errorMessage);
  }

  @override
  ErrorEditSavingsState getNewVersion() {
    return ErrorEditSavingsState(version + 1, errorMessage);
  }

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
