import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment_task/event/in_load_commitment_task_event.dart';
import 'package:wise_spends/bloc/state/display_message_state.dart';
import 'package:wise_spends/bloc/state/loading_state.dart';
import 'package:wise_spends/constant/enum/function_enum.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_task_vo.dart';

class UpdateStatusCommitmentTaskEvent extends IEvent<CommitmentTaskBloc> {
  final bool isDone;
  final CommitmentTaskVO taskVO;

  UpdateStatusCommitmentTaskEvent(this.isDone, this.taskVO);

  final ICommitmentManager _commitmentManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getCommitmentManager();

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    CommitmentTaskBloc? bloc,
  }) async* {
    yield const LoadingState(version: 0);

    await _commitmentManager.updateStatusCommitmentTask(isDone, taskVO);

    yield DisplayMessageState(
      message: 'Successfully update task status',
      actionAfterDisplay: (context) {
        final bloc = BlocProvider.of<CommitmentTaskBloc>(context);

        bloc.add(InLoadCommitmentTaskEvent());

        if (bloc.functionMap[FunctionEnum.updateAppBar] != null) {
          bloc.functionMap[FunctionEnum.updateAppBar]!([]);
        }
      },
      version: 0,
    );
  }
}
