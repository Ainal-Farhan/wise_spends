import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/impl/settings/state/settings_initial_state.dart';

class SettingsBloc extends IBloc<SettingsBloc> {
  SettingsBloc() : super(const SettingsInitialState(version: 0));
}