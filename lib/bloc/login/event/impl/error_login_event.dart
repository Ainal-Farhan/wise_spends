import 'dart:developer' as developer;

import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/login/state/impl/error_login_state.dart';
import 'package:wise_spends/constant/login/login_event_constant.dart';

class ErrorLoginEvent extends LoginEvent {
  @override
  Stream<LoginState> applyAsync(
      {LoginState? currentState, LoginBloc? bloc}) async* {
    try {
      yield const ErrorLoginState(LoginEventConstant.errorLoginEvent);
    } catch (ex, stackTrace) {
      developer.log('$ex',
          name: LoginEventConstant.errorLoginEvent,
          error: ex,
          stackTrace: stackTrace);
      yield ErrorLoginState(ex.toString());
    }
  }
}
