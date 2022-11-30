import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/index.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(LoginState initialState) : super(initialState) {
    on<LoginEvent>((event, emit) {
      return emit.forEach<LoginState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'LoginBloc', error: error, stackTrace: stackTrace);
          return ErrorLoginState(error.toString());
        },
      );
    });
  }
}
