import 'package:wise_spends/wise/spends/bloc/login/index.dart';

class LoginRepository {
  final LoginProvider _loginProvider = LoginProvider();

  LoginRepository();

  void test(bool isError) {
    _loginProvider.test(isError);
  }
}