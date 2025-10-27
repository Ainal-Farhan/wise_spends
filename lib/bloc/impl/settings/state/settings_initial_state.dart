import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/settings/settings_page.dart';

class SettingsInitialState extends IState<SettingsInitialState> {
  const SettingsInitialState({required super.version});

  @override
  String toString() => 'SettingsInitialState';

  @override
  Widget build(BuildContext context) {
    return const SettingsPage();
  }

  @override
  SettingsInitialState getNewVersion() => SettingsInitialState(version: version + 1);

  @override
  SettingsInitialState getStateCopy() => SettingsInitialState(version: version);
}