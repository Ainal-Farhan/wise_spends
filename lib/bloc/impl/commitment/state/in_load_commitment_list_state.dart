import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/event/add_commitment_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/delete_commitment_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/edit_commitment_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/load_list_commitment_detail_event.dart';
import 'package:wise_spends/bloc/impl/commitment/event/start_distribute_commitment_event.dart';
import 'package:wise_spends/resource/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_plus_button_round.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class InLoadCommitmentListState extends IState<InLoadCommitmentListState> {
  final List<CommitmentVO> commitmentVOList;

  const InLoadCommitmentListState(
      {required this.commitmentVOList, required super.version});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    List<ListTilesOneVO> commitmentListTilesOneVOList = [];

    for (int index = 0; index < commitmentVOList.length; index++) {
      commitmentListTilesOneVOList.add(
        ListTilesOneVO(
          index: index,
          title: commitmentVOList[index].name ?? '-',
          icon: const Icon(
            Icons.task,
            color: Color.fromARGB(255, 67, 18, 160),
          ),
          subtitleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commitmentVOList[index].description ?? '-',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                'From: ${commitmentVOList[index].referredSavingVO?.savingName ?? '-'}',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                'Total: RM ${(commitmentVOList[index].totalAmount ?? .0).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                'Commitment: ${commitmentVOList[index].commitmentDetailVOList.length}',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          trailingWidget: Wrap(
            direction: Axis.vertical,
            spacing: 10.0, // Adjust spacing as needed
            alignment: WrapAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_document,
                  color: Color.fromARGB(255, 67, 18, 160),
                ),
                onPressed: () => BlocProvider.of<CommitmentBloc>(context).add(
                    LoadListCommitmentDetailEvent(commitmentVOList[index])),
              ),
              IconButton(
                icon: const Icon(
                  Icons.start_rounded,
                  color: Color.fromARGB(255, 67, 18, 160),
                ),
                onPressed: () => showConfirmDialog(
                  context: context,
                  message: "Distribute Commitment?",
                  onConfirm: () async {
                    BlocProvider.of<CommitmentBloc>(context).add(
                        StartDistributeCommitmentEvent(
                            commitmentVOList[index]));
                  },
                ),
              ),
            ],
          ),
          onTap: () async => BlocProvider.of<CommitmentBloc>(context)
              .add(EditCommitmentEvent(toBeEdited: commitmentVOList[index])),
          onLongPressed: () async {
            showDeleteDialog(
              context: context,
              onDelete: () async {
                BlocProvider.of<CommitmentBloc>(context)
                    .add(DeleteCommitmentEvent(
                  toBeDeleted: commitmentVOList[index],
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
              emptyListMessage: 'No Commitment Available...',
            ),
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
                    .add(AddCommitmentEvent()),
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
