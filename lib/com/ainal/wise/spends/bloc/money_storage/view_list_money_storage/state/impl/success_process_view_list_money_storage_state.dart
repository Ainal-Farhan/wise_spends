import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';

class SuccessProcessViewListMoneyStorageState extends StatefulWidget
    implements ViewListMoneyStorageState {
  @override
  final int version;

  final String message;
  final String nextPageRoute;

  const SuccessProcessViewListMoneyStorageState({
    Key? key,
    required this.version,
    required this.message,
    required this.nextPageRoute,
  }) : super(key: key);

  @override
  State<SuccessProcessViewListMoneyStorageState> createState() =>
      _SuccessProcessViewListMoneyStorageStateState();

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  ViewListMoneyStorageState getNewVersion() =>
      SuccessProcessViewListMoneyStorageState(
        version: version + 1,
        message: message,
        nextPageRoute: nextPageRoute,
      );

  @override
  ViewListMoneyStorageState getStateCopy() =>
      SuccessProcessViewListMoneyStorageState(
        version: version,
        message: message,
        nextPageRoute: nextPageRoute,
      );

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class _SuccessProcessViewListMoneyStorageStateState
    extends State<SuccessProcessViewListMoneyStorageState> {
  @override
  void initState() {
    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(
        context,
        widget.nextPageRoute,
      );
    });
    super.initState();
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
            child: Text(widget.message),
          ),
        ),
      ],
    );
  }
}
