import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/state/loading_state.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

class DeleteCommitmentEvent extends IEvent<CommitmentBloc> {
  final CommitmentVO toBeDeleted;

  DeleteCommitmentEvent({required this.toBeDeleted});

  @override
  Stream<IState<dynamic>> applyAsync({
    IState<dynamic>? currentState,
    CommitmentBloc? bloc,
  }) async* {
    yield const LoadingState(version: 0);
  }
}
