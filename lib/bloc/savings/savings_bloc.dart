import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/bloc/savings/state/loading_savings_state.dart';

class SavingsBloc extends IBloc<SavingsBloc> {
  SavingsBloc() : super(const LoadingSavingsState(version: 0));
}
