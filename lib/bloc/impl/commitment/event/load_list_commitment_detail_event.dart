import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/state/in_load_commitment_detail_list_state.dart';
import 'package:wise_spends/bloc/impl/commitment/state/loading_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/manager/i_commitment_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

class LoadListCommitmentDetailEvent extends IEvent<CommitmentBloc> {
  CommitmentVO? selectedCommitmentVO;

  final ICommitmentManager _commitmentManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getCommitmentManager();

  LoadListCommitmentDetailEvent(this.selectedCommitmentVO);

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    CommitmentBloc? bloc,
  }) async* {
    yield const LoadingState(version: 0);

    selectedCommitmentVO ??= bloc!.selectedCommitmentVO;

    if (selectedCommitmentVO == null) {
      throw Exception("selected commitment is null!");
    }

    selectedCommitmentVO =
        await _commitmentManager.retrieveCommitmentVOBasedOnCommitmentId(
            selectedCommitmentVO!.commitmentId!);
    bloc!.selectedCommitmentVO = selectedCommitmentVO;

    yield InLoadCommitmentDetailListState(
      commitmentDetailVOList: selectedCommitmentVO!.commitmentDetailVOList,
      commitmentId: selectedCommitmentVO!.commitmentId!,
      version: 0,
    );
  }
}
