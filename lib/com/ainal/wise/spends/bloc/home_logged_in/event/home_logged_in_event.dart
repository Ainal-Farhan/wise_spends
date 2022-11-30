import 'dart:async';

import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';
import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/home_logged_in_state.dart';

@immutable
abstract class HomeLoggedInEvent {
  Stream<HomeLoggedInState> applyAsync(
      {HomeLoggedInState currentState, HomeLoggedInBloc bloc});
  final HomeLoggedInRepository _homeLoggedInRepository =
      HomeLoggedInRepository();

  HomeLoggedInRepository get homeLoggedInRepository => _homeLoggedInRepository;
}
