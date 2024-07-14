import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment_task/state/in_load_commitment_task_list_state.dart';
import 'package:wise_spends/bloc/state/loading_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_task_vo.dart';

class InLoadCommitmentTaskEvent extends IEvent<CommitmentTaskBloc> {
  final ICommitmentManager _commitmentManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getCommitmentManager();

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    CommitmentTaskBloc? bloc,
  }) async* {
    yield const LoadingState(version: 0);

    List<CommitmentTaskVO> commitmentTaskVOList =
        await _commitmentManager.retrieveListOfCommitmentTask(false);

    yield InLoadCommitmentTaskListState(commitmentTaskVOList, version: 0);
  }
}
