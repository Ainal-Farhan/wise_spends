import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/presentation/screens/login/bloc/login_bloc.dart';
import 'widgets/bottom_widget.dart';
import 'widgets/center_widget/center_widget.dart';
import 'widgets/login_content/login_content.dart';
import 'widgets/top_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc()..add(LoadLoginEvent()),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is InLoginState) {
            final screenSize = MediaQuery.of(context).size;
            return Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: -160,
                    left: -30,
                    child: TopWidget(screenWidth: screenSize.width),
                  ),
                  Positioned(
                    bottom: -180,
                    left: -40,
                    child: BottomWidget(screenWidth: screenSize.width),
                  ),
                  CenterWidget(size: screenSize),
                  const LoginContent(),
                ],
              ),
            );
          } else if (state is UnLoginState) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
