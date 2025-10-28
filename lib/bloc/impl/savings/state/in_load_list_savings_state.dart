import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/savings/components/list_savings/list_savings_widget.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_add_savings_form_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/constants/hero_tags.dart';
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
    return Column(
      children: [
        Expanded(
          child: ListSavingsWidget(listSavingVOList: _listSavingVOList),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FloatingActionButton(
            heroTag: HeroTagConstants.viewSavingForm,
            onPressed: () => BlocProvider.of<SavingsBloc>(context)
                .add(LoadAddSavingsFormEvent()),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
