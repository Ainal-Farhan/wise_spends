import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/login/widgets/bottom_widget.dart';
import 'package:wise_spends/bloc/login/widgets/center_widget/center_widget.dart';
import 'package:wise_spends/bloc/login/widgets/login_content/login_content.dart';
import 'package:wise_spends/bloc/login/widgets/top_widget.dart';

class InLoginState extends IState<InLoginState> {
  const InLoginState({
    required super.version,
    required this.hello,
  });

  final String hello;

  @override
  String toString() => 'InLoginState $hello';

  @override
  List<Object> get props => [hello];

  String get message => hello;

  @override
  Widget build(BuildContext context) {
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

  @override
  InLoginState getNewVersion() =>
      InLoginState(version: version + 1, hello: hello);

  @override
  InLoginState getStateCopy() => InLoginState(version: version, hello: hello);
}
