import 'package:wise_spends/bloc/edit_savings/state/un_edit_savings_state.dart';
import 'package:wise_spends/bloc/i_bloc.dart';

class EditSavingsBloc extends IBloc<EditSavingsBloc> {
  EditSavingsBloc() : super(const UnEditSavingsState(version: 0));
}
