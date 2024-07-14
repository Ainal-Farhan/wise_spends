import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_event.dart';

class SuccessSaveCommitmentState extends IState<SuccessSaveCommitmentState> {
  const SuccessSaveCommitmentState({
    required super.version,
  });

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;

  @override
  SuccessSaveCommitmentState getNewVersion() =>
      SuccessSaveCommitmentState(version: version + 1);

  @override
  SuccessSaveCommitmentState getStateCopy() =>
      SuccessSaveCommitmentState(version: version);

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 500), () {
      BlocProvider.of<CommitmentBloc>(context).add(LoadListCommitmentEvent());
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
            child: const Text('Successfully save commitment...'),
          ),
        ),
      ],
    );
  }
}
