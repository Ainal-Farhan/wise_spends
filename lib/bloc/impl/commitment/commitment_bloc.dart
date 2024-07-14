import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/state/loading_state.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

class CommitmentBloc extends IBloc<CommitmentBloc> {
  CommitmentVO? selectedCommitmentVO;

  CommitmentBloc() : super(const LoadingState(version: 0));
}
