import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/state/in_load_commitment_detail_form.dart';
import 'package:wise_spends/bloc/state/loading_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class AddCommitmentDetailEvent extends IEvent<CommitmentBloc> {
  final List<CommitmentDetailVO> commitmentDetailVOList;
  final String commitmentId;

  AddCommitmentDetailEvent(this.commitmentId, this.commitmentDetailVOList);

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    CommitmentBloc? bloc,
  }) async* {
    yield const LoadingState(version: 0);

    List<ListSavingVO> savingVOList =
        await SingletonUtil.getSingleton<IManagerLocator>()!
            .getSavingManager()
            .loadListSavingVOList();

    yield InLoadCommitmentDetailForm(
      CommitmentDetailVO(),
      savingVOList,
      version: 0,
    );
  }
}
