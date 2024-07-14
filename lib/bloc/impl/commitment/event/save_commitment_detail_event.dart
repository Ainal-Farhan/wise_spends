import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/state/success_process_commitment_detail_state.dart';
import 'package:wise_spends/bloc/state/loading_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';

class SaveCommitmentDetailEvent extends IEvent<CommitmentBloc> {
  final CommitmentDetailVO toBeSaved;
  final ICommitmentManager _commitmentManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getCommitmentManager();

  SaveCommitmentDetailEvent({required this.toBeSaved});

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    CommitmentBloc? bloc,
  }) async* {
    yield const LoadingState(version: 0);

    await _commitmentManager.saveCommitmentDetailVO(
        bloc!.selectedCommitmentVO!.commitmentId!, [toBeSaved]);

    yield const SuccessProsesCommitmentDetailState(
        version: 0, message: 'Successfully save the commitment detail.');
  }
}
