import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/login/state/error_login_state.dart';

class LoginBloc extends Bloc<IEvent<LoginBloc>, IState<dynamic>> {
  LoginBloc(super.initialState) {
    on<IEvent<LoginBloc>>((event, emit) {
      return emit.forEach<IState<dynamic>>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'LoginBloc', error: error, stackTrace: stackTrace);
          return ErrorLoginState(version: 0, errorMessage: error.toString());
        },
      );
    });
  }
}
