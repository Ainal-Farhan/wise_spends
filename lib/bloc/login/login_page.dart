import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/login/event/load_login_event.dart';
import 'package:wise_spends/bloc/login/login_bloc.dart';
import 'package:wise_spends/bloc/login/login_screen.dart';
import 'package:wise_spends/router/app_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = AppRouter.loginPageRoute;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: LoginScreen(
        bloc: loginBloc,
        initialEvent: LoadLoginEvent(),
      ),
    );
  }
}
