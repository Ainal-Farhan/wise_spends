import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class LoadingState extends IState<LoadingState> {
  const LoadingState({required super.version});

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
  LoadingState getNewVersion() => LoadingState(version: version + 1);

  @override
  LoadingState getStateCopy() => LoadingState(version: version);
}
