import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/state/loading_state.dart';
import 'package:wise_spends/bloc/impl/commitment/state/success_delete_commitment_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

class DeleteCommitmentEvent extends IEvent<CommitmentBloc> {
  final CommitmentVO toBeDeleted;
  final ICommitmentManager _commitmentManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getCommitmentManager();

  DeleteCommitmentEvent({required this.toBeDeleted});

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    CommitmentBloc? bloc,
  }) async* {
    yield const LoadingState(version: 0);

    await _commitmentManager.deleteCommitmentVO(toBeDeleted.commitmentId!);

    yield const SuccessProsesCommitmentState(
        version: 0, message: 'Successfully delete the selected Commitment');
  }
}
