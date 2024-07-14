import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_event.dart';
import 'package:wise_spends/components/forms/commitment_form.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class InLoadCommitmentForm extends IState<InLoadCommitmentForm> {
  final CommitmentVO commitmentVO;
  final List<ListSavingVO> savingVOList;

  const InLoadCommitmentForm(this.commitmentVO, this.savingVOList,
      {required super.version});

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
            child: CommitmentForm(
              commitmentVO: commitmentVO,
              savingVOList: savingVOList,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IThBackButtonRound(
                    onTap: () => BlocProvider.of<CommitmentBloc>(context)
                        .add(LoadListCommitmentEvent()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  InLoadCommitmentForm getNewVersion() =>
      InLoadCommitmentForm(commitmentVO, savingVOList, version: version + 1);

  @override
  InLoadCommitmentForm getStateCopy() =>
      InLoadCommitmentForm(commitmentVO, savingVOList, version: version);
}
