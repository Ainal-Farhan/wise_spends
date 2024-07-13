import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/screen.dart';

class CommitmentScreen
    extends StatefulWidgetScreen<CommitmentBloc, ScreenState<CommitmentBloc>> {
  const CommitmentScreen({
    required super.bloc,
    required super.initialEvent,
    super.key,
  });

  @override
  ScreenState<CommitmentBloc> createState() => ScreenState();
}
