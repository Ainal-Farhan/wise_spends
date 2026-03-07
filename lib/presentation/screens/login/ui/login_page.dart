import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/presentation/screens/login/ui/login_screen.dart';
import 'package:wise_spends/core/constants/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = AppRoutes.login;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('general.login'.tr)),
      body: LoginScreen(),
    );
  }
}
