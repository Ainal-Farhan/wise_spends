import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/savings/components/saving_transaction/saving_transaction_form_widget.dart';
import 'package:wise_spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';

class InSavingTransactionFormState extends SavingsState {
  final SvngSaving saving;

  const InSavingTransactionFormState({
    required int version,
    required this.saving,
  }) : super(version);

  @override
  Widget build(BuildContext context, Function load) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: screenHeight * .1,
          child: Container(),
        ),
        Center(
          child: SizedBox(
            height: screenHeight * .7,
            child: SavingTransactionFormWidget(
              saving: saving,
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
                  IThBackButtonRound(
                    onTap: () => load(savingsEvent: LoadListSavingsEvent()),
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
    return InSavingTransactionFormState(
      version: version + 1,
      saving: SvngSaving.fromJson(saving.toJson()),
    );
  }

  @override
  SavingsState getStateCopy() {
    return InSavingTransactionFormState(version: version, saving: saving);
  }
}
