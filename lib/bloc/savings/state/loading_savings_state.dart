import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class LoadingSavingsState extends IState<LoadingSavingsState> {
  const LoadingSavingsState({
    required super.version,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          Text('Loading...'),
        ],
      ),
    );
  }

  @override
  LoadingSavingsState getNewVersion() =>
      LoadingSavingsState(version: version + 1);

  @override
  LoadingSavingsState getStateCopy() => LoadingSavingsState(version: version);

  @override
  List<Object> get props => [version];
}
