import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';
import 'package:wise_spends/router/app_router.dart';

class SuccessAddMoneyStorageState extends StatefulWidget
    implements AddMoneyStorageState {
  @override
  final int version;

  const SuccessAddMoneyStorageState({
    Key? key,
    required this.version,
  }) : super(key: key);

  @override
  State<SuccessAddMoneyStorageState> createState() =>
      _SuccessAddMoneyStorageStateState();

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  AddMoneyStorageState getNewVersion() =>
      SuccessAddMoneyStorageState(version: version + 1);

  @override
  AddMoneyStorageState getStateCopy() =>
      SuccessAddMoneyStorageState(version: version);

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class _SuccessAddMoneyStorageStateState
    extends State<SuccessAddMoneyStorageState> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.viewListMoneyStoragePageRoute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
