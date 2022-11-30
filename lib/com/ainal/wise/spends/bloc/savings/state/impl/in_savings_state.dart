import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

/// Initialized
class InSavingsState extends SavingsState {
  const InSavingsState(int version, this.hello) : super(version);

  final String hello;

  @override
  String toString() => 'InSavingsState $hello';

  @override
  InSavingsState getStateCopy() {
    return InSavingsState(version, hello);
  }

  @override
  InSavingsState getNewVersion() {
    return InSavingsState(version + 1, hello);
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
