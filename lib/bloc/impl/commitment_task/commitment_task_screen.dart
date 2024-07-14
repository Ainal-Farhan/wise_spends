import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/bloc/screen.dart';

class CommitmentTaskScreen extends StatefulWidgetScreen<CommitmentTaskBloc,
    ScreenState<CommitmentTaskBloc>> {
  const CommitmentTaskScreen({
    required super.bloc,
    required super.initialEvent,
    super.key,
  });

  @override
  ScreenState<CommitmentTaskBloc> createState() => ScreenState();
}
