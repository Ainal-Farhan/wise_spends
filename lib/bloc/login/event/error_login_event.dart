import 'dart:developer' as developer;

import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/login/state/error_login_state.dart';
import 'package:wise_spends/constant/login/login_event_constant.dart';

class ErrorLoginEvent extends IEvent<LoginBloc> {
  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, LoginBloc? bloc}) async* {
    try {
      yield const ErrorLoginState(
          version: 0, errorMessage: LoginEventConstant.errorLoginEvent);
    } catch (ex, stackTrace) {
      developer.log('$ex',
          name: LoginEventConstant.errorLoginEvent,
          error: ex,
          stackTrace: stackTrace);
      yield ErrorLoginState(version: 0, errorMessage: ex.toString());
    }
  }
}
