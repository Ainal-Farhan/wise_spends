import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';

class SuccessProcessViewListMoneyStorageState
    extends IState<SuccessProcessViewListMoneyStorageState> {
  final String message;
  final String nextPageRoute;

  const SuccessProcessViewListMoneyStorageState({
    required super.version,
    required this.message,
    required this.nextPageRoute,
  });

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  SuccessProcessViewListMoneyStorageState getNewVersion() =>
      SuccessProcessViewListMoneyStorageState(
        version: version + 1,
        message: message,
        nextPageRoute: nextPageRoute,
      );

  @override
  SuccessProcessViewListMoneyStorageState getStateCopy() =>
      SuccessProcessViewListMoneyStorageState(
        version: version,
        message: message,
        nextPageRoute: nextPageRoute,
      );

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(
        context,
        nextPageRoute,
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
            child: Text(message),
          ),
        ),
      ],
    );
  }
}
