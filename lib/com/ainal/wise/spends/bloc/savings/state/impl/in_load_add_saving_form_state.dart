import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/forms/saving/i_th_add_saving_form.dart';

class InLoadAddSavingFormState extends SavingsState {
  const InLoadAddSavingFormState({
    required int version,
  }) : super(version);

  @override
  Widget build(BuildContext context, Function load) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: screenHeight * 0.1,
          child: Container(),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .7,
            child: IThAddSavingForm(
              eventLoader: load,
            ),
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
    return InLoadAddSavingFormState(version: version + 1);
  }

  @override
  SavingsState getStateCopy() {
    return InLoadAddSavingFormState(version: version);
  }
}
