import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

class LoadingSavingsState extends SavingsState {
  const LoadingSavingsState(final int version) : super(version);

  @override
  Widget build(BuildContext context, VoidCallback load) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        CircularProgressIndicator(),
        Text('Loading...'),
      ],
    ));
  }

  @override
  SavingsState getNewVersion() {
    return LoadingSavingsState(version + 1);
  }

  @override
  SavingsState getStateCopy() {
    return LoadingSavingsState(version);
  }

  @override
  List<Object> get props => [version];
}
