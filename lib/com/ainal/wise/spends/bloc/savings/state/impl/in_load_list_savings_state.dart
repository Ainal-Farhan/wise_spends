import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/components/list_savings/list_savings_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_add_savings_form_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';

class InLoadListSavingsState extends SavingsState {
  const InLoadListSavingsState(int version, this._savingWithTransactionsList)
      : super(version);

  final List<SavingWithTransactions> _savingWithTransactionsList;

  @override
  SavingsState getNewVersion() {
    return InLoadListSavingsState(version + 1, _savingWithTransactionsList);
  }

  @override
  SavingsState getStateCopy() {
    return InLoadListSavingsState(version, _savingWithTransactionsList);
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
            child: ListSavingsWidget(
                savingWithTransactionsList: _savingWithTransactionsList),
            height: screenHeight * 0.85,
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
