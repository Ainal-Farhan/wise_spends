import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class DisplayMessageState extends IState<DisplayMessageState> {
  final String message;
  final void Function(BuildContext)? actionAfterDisplay;
  final int delay;

  const DisplayMessageState({
    required super.version,
    required this.message,
    this.actionAfterDisplay,
    this.delay = 500,
  });

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  DisplayMessageState getNewVersion() => DisplayMessageState(
        version: version + 1,
        message: message,
      );

  @override
  DisplayMessageState getStateCopy() => DisplayMessageState(
        version: version,
        message: message,
      );

  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(milliseconds: delay),
      () {
        if (actionAfterDisplay != null) {
          actionAfterDisplay!(context);
        }
      },
    );

    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: screenHeight * 0.1,
          child: Container(),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .7,
            child: Text(message),
          ),
        ),
      ],
    );
  }
}
