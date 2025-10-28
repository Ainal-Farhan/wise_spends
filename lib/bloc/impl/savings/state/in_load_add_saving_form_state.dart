import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/theme/widgets/components/buttons/th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/forms/saving/th_add_saving_form.dart';

class InLoadAddSavingFormState extends IState<InLoadAddSavingFormState> {
  final List<DropDownValueModel> moneyStorageList;

  const InLoadAddSavingFormState({
    required super.version,
    required this.moneyStorageList,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Center(
            child: SizedBox(
              height: screenHeight * .7,
              child: ThAddSavingForm(
                // Add the necessary parameters for the updated widget
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
                    ThBackButtonRound(
                      onTap: () => BlocProvider.of<SavingsBloc>(
                        context,
                      ).add(LoadListSavingsEvent()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  InLoadAddSavingFormState getNewVersion() => InLoadAddSavingFormState(
    version: version + 1,
    moneyStorageList: [...moneyStorageList],
  );

  @override
  InLoadAddSavingFormState getStateCopy() => InLoadAddSavingFormState(
    version: version,
    moneyStorageList: [...moneyStorageList],
  );
}
