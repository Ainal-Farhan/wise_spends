import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/impl/theme/state/theme_initial_state.dart';

class ThemeBloc extends IBloc<ThemeBloc> {
  ThemeBloc() : super(const ThemeInitialState(version: 0));
}