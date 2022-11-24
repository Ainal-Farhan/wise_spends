import 'package:wise_spends/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/wise/spends/bloc/login/state/index.dart';

class UnLoginEvent extends LoginEvent {
  @override
  Stream<LoginState> applyAsync(
      {LoginState? currentState, LoginBloc? bloc}) async* {
    yield const UnLoginState();
  }
}
