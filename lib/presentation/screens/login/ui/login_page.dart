import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/screens/login/ui/login_screen.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: LoginScreen(),
    );
  }
}
