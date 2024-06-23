import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/login/event/error_login_event.dart';
import 'package:wise_spends/bloc/login/event/load_login_event.dart';
import 'package:wise_spends/bloc/login/event/un_login_event.dart';
import 'package:wise_spends/bloc/login/login_bloc.dart';
import 'package:wise_spends/constant/login/login_event_constant.dart';

class LoginEventFactory {
  LoginEventFactory._privateConstructor();

  static final LoginEventFactory _loginEventFactory =
      LoginEventFactory._privateConstructor();

  factory LoginEventFactory() {
    return _loginEventFactory;
  }

  IEvent<LoginBloc> getLoginEvent(final String loginEventName) {
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
