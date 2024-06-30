import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/money_storage/events/in_load_view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_bloc.dart';

class SuccessProcessViewListMoneyStorageState
    extends IState<SuccessProcessViewListMoneyStorageState> {
  final String message;

  const SuccessProcessViewListMoneyStorageState({
    required super.version,
    required this.message,
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
      );

  @override
  SuccessProcessViewListMoneyStorageState getStateCopy() =>
      SuccessProcessViewListMoneyStorageState(
        version: version,
        message: message,
      );

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<MoneyStorageBloc>(context)
          .add(InLoadViewListMoneyStorageEvent());
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
