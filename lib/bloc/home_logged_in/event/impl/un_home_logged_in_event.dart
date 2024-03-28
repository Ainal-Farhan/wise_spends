import 'package:wise_spends/bloc/home_logged_in/event/home_logged_in_event.dart';
import 'package:wise_spends/bloc/home_logged_in/home_logged_in_bloc.dart';
import 'package:wise_spends/bloc/home_logged_in/state/home_logged_in_state.dart';
import 'package:wise_spends/bloc/home_logged_in/state/impl/un_home_logged_in_state.dart';

class UnHomeLoggedInEvent extends HomeLoggedInEvent {
  @override
  Stream<HomeLoggedInState> applyAsync(
      {HomeLoggedInState? currentState, HomeLoggedInBloc? bloc}) async* {
    yield const UnHomeLoggedInState(0);
  }
}
