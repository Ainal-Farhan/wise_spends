import 'dart:async';

import 'package:meta/meta.dart';

import 'package:wise_spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/bloc/home_logged_in/state/home_logged_in_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_home_logged_in_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

@immutable
abstract class HomeLoggedInEvent {
  Stream<HomeLoggedInState> applyAsync(
      {HomeLoggedInState currentState, HomeLoggedInBloc bloc});
  final IHomeLoggedInManager _homeLoggedInManager =
      SingletonUtil.getSingleton<IManagerLocator>().getHomeLoggedInManager();

  IHomeLoggedInManager get homeLoggedInManager => _homeLoggedInManager;
}
