import 'dart:developer' as developer;

import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/login/state/error_login_state.dart';
import 'package:wise_spends/bloc/login/state/in_login_state.dart';
import 'package:wise_spends/bloc/login/state/un_login_state.dart';

class LoadLoginEvent extends IEvent<LoginBloc> {
  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, LoginBloc? bloc}) async* {
    try {
      yield const UnLoginState(version: 0);
      await Future.delayed(const Duration(seconds: 1));
      yield const InLoginState(version: 0, hello: 'Hello world');
    } catch (ex, stackTrace) {
      developer.log('$ex',
          name: 'LoadLoginEvent', error: ex, stackTrace: stackTrace);
      yield ErrorLoginState(version: 0, errorMessage: ex.toString());
    }
  }
}
