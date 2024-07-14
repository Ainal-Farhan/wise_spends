import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/state/loading_state.dart';

class CommitmentTaskBloc extends IBloc<CommitmentTaskBloc> {
  CommitmentTaskBloc() : super(const LoadingState(version: 0));
}
