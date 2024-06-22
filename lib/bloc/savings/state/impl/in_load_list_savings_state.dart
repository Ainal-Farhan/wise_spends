import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/savings/components/list_savings/list_savings_widget.dart';
import 'package:wise_spends/bloc/savings/event/impl/load_add_savings_form_event.dart';
import 'package:wise_spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

class InLoadListSavingsState extends SavingsState {
  const InLoadListSavingsState(super.version, this._listSavingVOList);

  final List<ListSavingVO> _listSavingVOList;

  @override
  SavingsState getNewVersion() {
    return InLoadListSavingsState(version + 1, _listSavingVOList);
  }

  @override
  SavingsState getStateCopy() {
    return InLoadListSavingsState(version, _listSavingVOList);
  }

  @override
  Widget build(BuildContext context, Function load) {
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
              Ink(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(400.0),
                  onTap: () => load(savingsEvent: LoadAddSavingsFormEvent()),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add,
                      size: 30.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
