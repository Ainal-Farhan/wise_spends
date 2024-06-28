import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/savings/components/list_savings/list_savings_widget.dart';
import 'package:wise_spends/bloc/savings/event/load_add_savings_form_event.dart';
import 'package:wise_spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_plus_button_round.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class InLoadListSavingsState extends IState<InLoadListSavingsState> {
  const InLoadListSavingsState(this._listSavingVOList,
      {required super.version});

  final List<ListSavingVO> _listSavingVOList;

  @override
  InLoadListSavingsState getNewVersion() =>
      InLoadListSavingsState(_listSavingVOList, version: version + 1);

  @override
  InLoadListSavingsState getStateCopy() =>
      InLoadListSavingsState(_listSavingVOList, version: version);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: screenHeight * 0.8,
            child: ListSavingsWidget(listSavingVOList: _listSavingVOList),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IThPlusButtonRound(
                onTap: () => BlocProvider.of<SavingsBloc>(context)
                    .add(LoadAddSavingsFormEvent()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
