import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class UnLoginState extends IState<UnLoginState> {
  const UnLoginState({required super.version});

  @override
  String toString() => 'UnLoginState';

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  UnLoginState getNewVersion() => UnLoginState(version: version + 1);

  @override
  UnLoginState getStateCopy() => UnLoginState(version: version);
}
