import 'dart:developer' as developer;

import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/impl/error_login_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/login/login_event_constant.dart';

class ErrorLoginEvent extends LoginEvent {
  @override
  Stream<LoginState> applyAsync(
      {LoginState? currentState, LoginBloc? bloc}) async* {
    try {
      yield const ErrorLoginState(LoginEventConstant.errorLoginEvent);
    } catch (_, stackTrace) {
      developer.log('$_',
          name: LoginEventConstant.errorLoginEvent,
          error: _,
          stackTrace: stackTrace);
      yield ErrorLoginState(_.toString());
    }
  }
}
