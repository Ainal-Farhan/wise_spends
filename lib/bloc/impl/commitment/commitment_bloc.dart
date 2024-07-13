import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment/state/loading_state.dart';

class CommitmentBloc extends IBloc<CommitmentBloc> {
  CommitmentBloc() : super(const LoadingState(version: 0));
}
