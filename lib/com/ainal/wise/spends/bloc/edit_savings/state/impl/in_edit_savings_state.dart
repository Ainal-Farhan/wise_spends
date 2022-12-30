import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/impl/load_edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';

/// Initialized
class InEditSavingsState extends EditSavingsState {
  const InEditSavingsState(int version, this.hello) : super(version: version);

  final String hello;

  @override
  String toString() => 'InEditSavingsState $hello';

  @override
  InEditSavingsState getStateCopy() {
    return InEditSavingsState(version, hello);
  }

  @override
  InEditSavingsState getNewVersion() {
    return InEditSavingsState(version + 1, hello);
  }

  @override
  List<Object> get props => [version, hello];

  @override
  Widget build(BuildContext context) {
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
              onPressed: () =>
                  EditSavingsBloc().add(LoadEditSavingsEvent(true)),
              child: const Text('throw error'),
            ),
          ),
        ],
      ),
    );
  }
}
