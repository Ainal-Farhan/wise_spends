import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/login/state/in_login_state.dart';
import 'package:wise_spends/bloc/login/state/un_login_state.dart';
import 'package:wise_spends/constant/login/login_state_constant.dart';

class LoginStateFactory {
  LoginStateFactory._privateConstructor();

  static final LoginStateFactory _loginStateFactory =
      LoginStateFactory._privateConstructor();

  factory LoginStateFactory() {
    return _loginStateFactory;
  }

  IState<dynamic> getLoginState(final String loginStateName) {
    switch (loginStateName) {
      case LoginStateConstant.inLoginState:
        return const InLoginState(version: 0, hello: LoginStateConstant.inLoginStateMessage);
      case LoginStateConstant.unLoginState:
        return const UnLoginState(version: 0);
      default:
        return const UnLoginState(version: 0);
    }
  }

  bool isLoginState(final IState<dynamic> loginState, final String loginStateName) {
    switch (loginStateName) {
      case LoginStateConstant.inLoginState:
        return loginState is InLoginState;
      case LoginStateConstant.unLoginState:
        return loginState is UnLoginState;
      default:
        return false;
    }
  }
}
