import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/impl/login/state/un_login_state.dart';

class LoginBloc extends IBloc<LoginBloc> {
  LoginBloc() : super(const UnLoginState(version: 0));
}
