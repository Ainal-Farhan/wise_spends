import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/home_logged_in/state/home_logged_in_state.dart';

/// UnInitialized
class UnHomeLoggedInState extends HomeLoggedInState {
  const UnHomeLoggedInState(int version) : super(version);

  @override
  String toString() => 'UnHomeLoggedInState';

  @override
  UnHomeLoggedInState getStateCopy() {
    return const UnHomeLoggedInState(0);
  }

  @override
  UnHomeLoggedInState getNewVersion() {
    return UnHomeLoggedInState(version + 1);
  }

  @override
  Widget build(BuildContext context, VoidCallback load) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
