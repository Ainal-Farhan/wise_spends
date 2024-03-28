import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/home_logged_in/event/home_logged_in_event.dart';
import 'package:wise_spends/bloc/home_logged_in/state/home_logged_in_state.dart';
import 'package:wise_spends/bloc/home_logged_in/state/impl/error_home_logged_in_state.dart';
import 'package:wise_spends/bloc/home_logged_in/state/impl/un_home_logged_in_state.dart';

class HomeLoggedInBloc extends Bloc<HomeLoggedInEvent, HomeLoggedInState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct
  static final HomeLoggedInBloc _homeLoggedInBlocSingleton =
      HomeLoggedInBloc._internal();
  factory HomeLoggedInBloc() {
    return _homeLoggedInBlocSingleton;
  }

  HomeLoggedInBloc._internal() : super(const UnHomeLoggedInState(0)) {
    on<HomeLoggedInEvent>((event, emit) {
      return emit.forEach<HomeLoggedInState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'HomeLoggedInBloc', error: error, stackTrace: stackTrace);
          return ErrorHomeLoggedInState(0, error.toString());
        },
      );
    });
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }
}
