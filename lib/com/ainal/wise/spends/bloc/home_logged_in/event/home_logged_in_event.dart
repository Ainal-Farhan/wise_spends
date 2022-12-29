import 'dart:async';

import 'package:meta/meta.dart';

import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/home_logged_in_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_home_logged_in_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/home_logged_in_manager.dart';

@immutable
abstract class HomeLoggedInEvent {
  Stream<HomeLoggedInState> applyAsync(
      {HomeLoggedInState currentState, HomeLoggedInBloc bloc});
  final IHomeLoggedInManager _homeLoggedInManager = HomeLoggedInManager();

  IHomeLoggedInManager get homeLoggedInManager => _homeLoggedInManager;
}
