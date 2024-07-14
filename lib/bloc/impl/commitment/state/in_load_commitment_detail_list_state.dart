import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/add_commitment_detail_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/delete_commitment_detail_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/edit_commitment_detail_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_event.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_plus_button_round.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class InLoadCommitmentDetailListState
    extends IState<InLoadCommitmentDetailListState> {
  final String commitmentId;
  final List<CommitmentDetailVO> commitmentDetailVOList;

  const InLoadCommitmentDetailListState({
    required this.commitmentDetailVOList,
    required this.commitmentId,
    required super.version,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    List<ListTilesOneVO> commitmentListTilesOneVOList = [];

    for (int index = 0; index < commitmentDetailVOList.length; index++) {
      commitmentListTilesOneVOList.add(
        ListTilesOneVO(
          index: index,
          title: commitmentDetailVOList[index].description ?? '-',
          icon: const Icon(
            Icons.task,
            color: Color.fromARGB(255, 67, 18, 160),
          ),
          subtitleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Savings: ${commitmentDetailVOList[index].referredSavingVO?.savingName ?? '-'}',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                'Total: RM ${(commitmentDetailVOList[index].amount ?? .0).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          onTap: () async => BlocProvider.of<CommitmentBloc>(context)
              .add(EditCommitmentDetailEvent(
            toBeEdited: commitmentDetailVOList[index],
          )),
          onLongPressed: () async {
            showDeleteDialog(
              context: context,
              onDelete: () async {
                BlocProvider.of<CommitmentBloc>(context)
                    .add(DeleteCommitmentDetailEvent(
                  toBeDeleted: commitmentDetailVOList[index],
                ));
              },
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: screenHeight * 0.8,
            child: IThListTilesOne(
              items: commitmentListTilesOneVOList,
              emptyListMessage: 'No Commitment Detail Available...',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IThBackButtonRound(
                onTap: () => BlocProvider.of<CommitmentBloc>(context)
                    .add(LoadListCommitmentEvent()),
              ),
              IThPlusButtonRound(
                onTap: () => BlocProvider.of<CommitmentBloc>(context).add(
                    AddCommitmentDetailEvent(
                        commitmentId, commitmentDetailVOList)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  InLoadCommitmentDetailListState getNewVersion() =>
      InLoadCommitmentDetailListState(
        commitmentDetailVOList: commitmentDetailVOList,
        version: version + 1,
        commitmentId: commitmentId,
      );

  @override
  InLoadCommitmentDetailListState getStateCopy() =>
      InLoadCommitmentDetailListState(
        commitmentDetailVOList: commitmentDetailVOList,
        version: version,
        commitmentId: commitmentId,
      );
}
