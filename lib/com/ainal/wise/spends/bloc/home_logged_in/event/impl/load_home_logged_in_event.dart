import 'dart:async';
import 'dart:developer' as developer;

import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/event/home_logged_in_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/home_logged_in_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/home_logged_in_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/impl/error_home_logged_in_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/impl/in_home_logged_in_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/impl/un_home_logged_in_state.dart';

class LoadHomeLoggedInEvent extends HomeLoggedInEvent {
  final bool isError;
  @override
  String toString() => 'LoadHomeLoggedInEvent';

  LoadHomeLoggedInEvent(this.isError);

  @override
  Stream<HomeLoggedInState> applyAsync(
      {HomeLoggedInState? currentState, HomeLoggedInBloc? bloc}) async* {
    try {
      yield const UnHomeLoggedInState(0);
      await Future.delayed(const Duration(seconds: 1));
      homeLoggedInManager.test(isError);
      yield const InHomeLoggedInState(0, 'Hello world');
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadHomeLoggedInEvent', error: _, stackTrace: stackTrace);
      yield ErrorHomeLoggedInState(0, _.toString());
    }
  }
}
