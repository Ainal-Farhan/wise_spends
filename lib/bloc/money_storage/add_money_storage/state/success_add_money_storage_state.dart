import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/router/app_router.dart';

class SuccessAddMoneyStorageState extends IState<SuccessAddMoneyStorageState> {
  const SuccessAddMoneyStorageState({
    required super.version,
  });

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  SuccessAddMoneyStorageState getNewVersion() =>
      SuccessAddMoneyStorageState(version: version + 1);

  @override
  SuccessAddMoneyStorageState getStateCopy() =>
      SuccessAddMoneyStorageState(version: version);

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.viewListMoneyStoragePageRoute,
      );
    });

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
            child: const Text('Successfully add new money storage...'),
          ),
        ),
      ],
    );
  }
}
