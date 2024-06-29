import 'package:wise_spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/bloc/screen.dart';

class SavingsScreen
    extends StatefulWidgetScreen<SavingsBloc, ScreenState<SavingsBloc>> {
  const SavingsScreen({
    required super.bloc,
    required super.initialEvent,
    super.key,
  });

  @override
  ScreenState<SavingsBloc> createState() => ScreenState();
}
