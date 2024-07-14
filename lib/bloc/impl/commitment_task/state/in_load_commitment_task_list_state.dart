import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment_task/event/update_status_commitment_task_event.dart';
import 'package:wise_spends/resource/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_task_vo.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class InLoadCommitmentTaskListState
    extends IState<InLoadCommitmentTaskListState> {
  final List<CommitmentTaskVO> commitmentTaskVOList;

  const InLoadCommitmentTaskListState(this.commitmentTaskVOList,
      {required super.version});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    List<ListTilesOneVO> taskListTilesOneVOList = [];

    for (int index = 0; index < commitmentTaskVOList.length; index++) {
      taskListTilesOneVOList.add(
        ListTilesOneVO(
          index: index,
          title: commitmentTaskVOList[index].name ?? '-',
          icon: const Icon(
            Icons.task,
            color: Color.fromARGB(255, 67, 18, 160),
          ),
          subtitleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${commitmentTaskVOList[index].referredSavingVO?.savingName ?? '-'} (${commitmentTaskVOList[index].moneyStorage?.shortName ?? '-'})',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                'RM ${(commitmentTaskVOList[index].amount ?? .0).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black),
              )
            ],
          ),
          trailingWidget: Wrap(
            direction: Axis.vertical,
            spacing: 10.0, // Adjust spacing as needed
            alignment: WrapAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.check_circle,
                  color: Color.fromARGB(255, 22, 211, 57),
                ),
                onPressed: () => showConfirmDialog(
                  context: context,
                  message: "Task already completed?",
                  onConfirm: () async =>
                      BlocProvider.of<CommitmentTaskBloc>(context).add(
                          UpdateStatusCommitmentTaskEvent(
                              true, commitmentTaskVOList[index])),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: Color.fromARGB(255, 255, 0, 0),
                ),
                onPressed: () => showConfirmDialog(
                  context: context,
                  message: "Remove task?",
                  onConfirm: () async =>
                      BlocProvider.of<CommitmentTaskBloc>(context).add(
                          UpdateStatusCommitmentTaskEvent(
                              false, commitmentTaskVOList[index])),
                ),
              ),
            ],
          ),
          onTap: () async => {},
          onLongPressed: () async => {},
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
              items: taskListTilesOneVOList,
              emptyListMessage: 'No Task Available...',
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
            ],
          ),
        ],
      ),
    );
  }

  @override
  InLoadCommitmentTaskListState getNewVersion() =>
      InLoadCommitmentTaskListState(commitmentTaskVOList, version: version + 1);

  @override
  InLoadCommitmentTaskListState getStateCopy() =>
      InLoadCommitmentTaskListState(commitmentTaskVOList, version: version);
}
