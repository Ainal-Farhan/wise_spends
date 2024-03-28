import 'dart:developer' as developer;

import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/login/state/impl/error_login_state.dart';
import 'package:wise_spends/bloc/login/state/impl/in_login_state.dart';
import 'package:wise_spends/bloc/login/state/impl/un_login_state.dart';

class LoadLoginEvent extends LoginEvent {
  @override
  Stream<LoginState> applyAsync(
      {LoginState? currentState, LoginBloc? bloc}) async* {
    try {
      yield const UnLoginState();
      await Future.delayed(const Duration(seconds: 1));
      yield const InLoginState('Hello world');
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadLoginEvent', error: _, stackTrace: stackTrace);
      yield ErrorLoginState(_.toString());
    }
  }
}
