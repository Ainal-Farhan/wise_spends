import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';

class SuccessEditMoneyStorageState extends StatefulWidget
    implements EditMoneyStorageState {
  @override
  final int version;

  const SuccessEditMoneyStorageState({
    Key? key,
    required this.version,
  }) : super(key: key);

  @override
  State<SuccessEditMoneyStorageState> createState() =>
      _SuccessEditMoneyStorageStateState();

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
    throw UnimplementedError();
  }
}

class _SuccessEditMoneyStorageStateState
    extends State<SuccessEditMoneyStorageState> {
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
            child: const Text('Successfully edit the money storage...'),
          ),
        ),
      ],
    );
  }
}
