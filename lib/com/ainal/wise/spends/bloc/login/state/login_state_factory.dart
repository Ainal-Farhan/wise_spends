import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/impl/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/login/login_state_constant.dart';

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
