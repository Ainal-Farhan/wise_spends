import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/login/login_bloc.dart';
import 'package:wise_spends/bloc/impl/login/state/in_login_state.dart';
import 'package:wise_spends/bloc/impl/login/state/un_login_state.dart';

class LoadLoginEvent extends IEvent<LoginBloc> {
  @override
  Stream<IState<dynamic>> applyAsync(
      {IState<dynamic>? currentState, LoginBloc? bloc}) async* {
    yield const UnLoginState(version: 0);
    await Future.delayed(const Duration(seconds: 1));
    yield const InLoginState(version: 0, hello: 'Hello world');
  }
}
