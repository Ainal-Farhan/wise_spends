import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_detail_event.dart';

class SuccessProsesCommitmentDetailState
    extends IState<SuccessProsesCommitmentDetailState> {
  final String message;

  const SuccessProsesCommitmentDetailState({
    required super.version,
    required this.message,
  });

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  SuccessProsesCommitmentDetailState getNewVersion() =>
      SuccessProsesCommitmentDetailState(
        version: version + 1,
        message: message,
      );

  @override
  SuccessProsesCommitmentDetailState getStateCopy() =>
      SuccessProsesCommitmentDetailState(
        version: version,
        message: message,
      );

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<CommitmentBloc>(context)
          .add(LoadListCommitmentDetailEvent(null));
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
