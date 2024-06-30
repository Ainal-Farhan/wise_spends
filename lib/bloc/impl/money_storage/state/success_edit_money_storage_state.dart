import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/money_storage/events/in_load_view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_bloc.dart';

class SuccessEditMoneyStorageState
    extends IState<SuccessEditMoneyStorageState> {
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
            child: const Text('Successfully edit the money storage...'),
          ),
        ),
      ],
    );
  }
}
