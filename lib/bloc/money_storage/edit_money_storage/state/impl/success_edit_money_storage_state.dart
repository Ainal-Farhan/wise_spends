import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/router/app_router.dart';

class SuccessEditMoneyStorageState extends EditMoneyStorageState {
  const SuccessEditMoneyStorageState({
    required int version,
  }) : super(version: version);

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  EditMoneyStorageState getNewVersion() =>
      SuccessEditMoneyStorageState(version: version + 1);

  @override
  EditMoneyStorageState getStateCopy() =>
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
