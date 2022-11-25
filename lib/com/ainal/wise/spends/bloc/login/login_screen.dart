import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/event/login_event_factory.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/login_state_factory.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/widgets/bottom_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/widgets/center_widget/center_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/widgets/login_content/login_content.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/widgets/top_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/login/login_event_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/login/login_state_constant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required LoginBloc loginBloc,
    Key? key,
  })  : _loginBloc = loginBloc,
        super(key: key);

  final LoginBloc _loginBloc;

  @override
  LoginScreenState createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  LoginScreenState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        bloc: widget._loginBloc,
        builder: (
          BuildContext context,
          LoginState currentState,
        ) {
          if (LoginStateFactory()
              .isLoginState(currentState, LoginStateConstant.unLoginState)) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (LoginStateFactory()
              .isLoginState(currentState, LoginStateConstant.errorLoginState)) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(currentState.message),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton(
                    child: const Text('reload'),
                    onPressed: _load,
                  ),
                ),
              ],
            ));
          }
          if (LoginStateFactory()
              .isLoginState(currentState, LoginStateConstant.inLoginState)) {
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
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void _load() {
    widget._loginBloc.add(
        LoginEventFactory().getLoginEvent(LoginEventConstant.loadLoginEvent));
  }
}
