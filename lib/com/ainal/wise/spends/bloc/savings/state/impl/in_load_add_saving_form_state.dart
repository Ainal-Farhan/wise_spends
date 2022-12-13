import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/add_saving/saving_form_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_list_savings_event.dart';

import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/add_saving_form_vo.dart';

class InLoadAddSavingFormState extends SavingsState {
  final AddSavingFormVO addSavingFormVO;

  const InLoadAddSavingFormState({
    required int version,
    required this.addSavingFormVO,
  }) : super(version);

  @override
  Widget build(BuildContext context, Function load) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: <Widget>[
        Center(
          child: SizedBox(
            child: SavingFormWidget(
              addSavingFormVO: addSavingFormVO,
              eventLoader: load,
            ),
            height: screenHeight * 0.65,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Ink(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(400.0),
                      onTap: () => load(savingsEvent: LoadListSavingsEvent()),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.arrow_back,
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
        ),
      ],
    );
  }

  @override
  SavingsState getNewVersion() {
    return InLoadAddSavingFormState(
        version: version + 1, addSavingFormVO: addSavingFormVO);
  }

  @override
  SavingsState getStateCopy() {
    return InLoadAddSavingFormState(
        version: version, addSavingFormVO: addSavingFormVO);
  }
}
