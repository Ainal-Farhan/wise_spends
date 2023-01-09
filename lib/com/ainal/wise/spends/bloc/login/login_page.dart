import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/impl/un_login_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({key}) : super(key: key);

  static const String routeName = AppRouter.loginPageRoute;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginBloc = LoginBloc(const UnLoginState());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: LoginScreen(
        loginBloc: _loginBloc,
      ),
    );
  }
}
