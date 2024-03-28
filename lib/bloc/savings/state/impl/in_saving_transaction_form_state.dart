import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/savings/components/saving_transaction/saving_transaction_form_widget.dart';
import 'package:wise_spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/db/app_database.dart';

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
