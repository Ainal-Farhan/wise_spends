import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_detail_event.dart';
import 'package:wise_spends/components/forms/commitment_detail_form.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class InLoadCommitmentDetailForm extends IState<InLoadCommitmentDetailForm> {
  final CommitmentDetailVO commitmentDetailVO;
  final List<ListSavingVO> savingVOList;

  const InLoadCommitmentDetailForm(this.commitmentDetailVO, this.savingVOList,
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
            child: CommitmentDetailForm(
              commitmentDetailVO: commitmentDetailVO,
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
                        .add(LoadListCommitmentDetailEvent(null)),
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
  InLoadCommitmentDetailForm getNewVersion() =>
      InLoadCommitmentDetailForm(commitmentDetailVO, savingVOList,
          version: version + 1);

  @override
  InLoadCommitmentDetailForm getStateCopy() =>
      InLoadCommitmentDetailForm(commitmentDetailVO, savingVOList,
          version: version);
}
