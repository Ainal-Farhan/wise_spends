import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/router/app_router.dart';

class SuccessEditMoneyStorageState extends IState<SuccessEditMoneyStorageState> {
  const SuccessEditMoneyStorageState({
    required super.version,
  });

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  SuccessEditMoneyStorageState getNewVersion() =>
      SuccessEditMoneyStorageState(version: version + 1);

  @override
  SuccessEditMoneyStorageState getStateCopy() =>
      SuccessEditMoneyStorageState(version: version);

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 1000), () {
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
            child: const Text('Successfully edit the money storage...'),
          ),
        ),
      ],
    );
  }
}
