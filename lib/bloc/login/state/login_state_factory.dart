import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/login/state/impl/error_login_state.dart';
import 'package:wise_spends/bloc/login/state/impl/in_login_state.dart';
import 'package:wise_spends/bloc/login/state/impl/un_login_state.dart';
import 'package:wise_spends/constant/login/login_state_constant.dart';

class LoginStateFactory {
  LoginStateFactory._privateConstructor();

  static final LoginStateFactory _loginStateFactory =
      LoginStateFactory._privateConstructor();

  factory LoginStateFactory() {
    return _loginStateFactory;
  }

  LoginState getLoginState(final String loginStateName) {
    switch (loginStateName) {
      case LoginStateConstant.inLoginState:
        return const InLoginState(LoginStateConstant.inLoginStateMessage);
      case LoginStateConstant.unLoginState:
        return const UnLoginState();
      default:
        return const ErrorLoginState("");
    }
  }

  bool isLoginState(final LoginState loginState, final String loginStateName) {
    switch (loginStateName) {
      case LoginStateConstant.inLoginState:
        return loginState is InLoginState;
      case LoginStateConstant.unLoginState:
        return loginState is UnLoginState;
      case LoginStateConstant.errorLoginState:
        return loginState is ErrorLoginState;
      default:
        return false;
    }
  }
}
