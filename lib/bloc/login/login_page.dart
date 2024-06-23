import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/login/state/un_login_state.dart';
import 'package:wise_spends/router/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = AppRouter.loginPageRoute;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginBloc = LoginBloc(const UnLoginState(version: 0));

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
