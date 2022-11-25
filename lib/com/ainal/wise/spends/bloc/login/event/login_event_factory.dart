import 'package:wise_spends/com/ainal/wise/spends/bloc/login/event/impl/error_login_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/event/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/login/login_event_constant.dart';

class LoginEventFactory {
  LoginEventFactory._privateConstructor();

  static final LoginEventFactory _loginEventFactory =
      LoginEventFactory._privateConstructor();

  factory LoginEventFactory() {
    return _loginEventFactory;
  }

  LoginEvent getLoginEvent(final String loginEventName) {
    switch (loginEventName) {
      case LoginEventConstant.loadLoginEvent:
        return LoadLoginEvent();
      case LoginEventConstant.unLoginEvent:
        return UnLoginEvent();
      default:
        return ErrorLoginEvent();
    }
  }
}
