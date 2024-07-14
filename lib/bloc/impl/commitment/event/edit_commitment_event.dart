import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/state/in_load_commitment_form.dart';
import 'package:wise_spends/bloc/impl/commitment/state/loading_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class EditCommitmentEvent extends IEvent<CommitmentBloc> {
  final CommitmentVO toBeEdited;

  EditCommitmentEvent({required this.toBeEdited});

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

    yield InLoadCommitmentForm(toBeEdited, savingVOList, version: 0);
  }
}
