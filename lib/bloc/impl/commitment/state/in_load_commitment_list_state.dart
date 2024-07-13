import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_event.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_plus_button_round.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

class InLoadCommitmentListState extends IState<InLoadCommitmentListState> {
  final List<CommitmentVO> commitmentVOList;

  const InLoadCommitmentListState(
      {required this.commitmentVOList, required super.version});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: screenHeight * 0.8,
            child: Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IThBackButtonRound(
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRouter.savingsPageRoute,
                ),
              ),
              IThPlusButtonRound(
                onTap: () => BlocProvider.of<CommitmentBloc>(context)
                    .add(LoadListCommitmentEvent()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  InLoadCommitmentListState getNewVersion() => InLoadCommitmentListState(
      commitmentVOList: commitmentVOList, version: version + 1);

  @override
  InLoadCommitmentListState getStateCopy() => InLoadCommitmentListState(
      commitmentVOList: commitmentVOList, version: version);
}
