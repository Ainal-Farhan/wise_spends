import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/wise/spends/bloc/login/state/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    LoginBloc loginBloc = LoginBloc(const UnLoginState());
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => loginBloc,
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return LoginScreen(loginBloc: loginBloc);
          },
        ),
      ),
    );
  }
}
