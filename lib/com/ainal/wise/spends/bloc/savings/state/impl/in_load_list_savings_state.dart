import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';

class InLoadListSavingsState extends SavingsState {
  final List<SavingWithTransactions> _savingWithTransactionsList;

  const InLoadListSavingsState(int version, this._savingWithTransactionsList)
      : super(version);

  @override
  Widget build(BuildContext context, VoidCallback load) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _savingWithTransactionsList.length,
      itemBuilder: (BuildContext context, int index) {
        return _makeCard(index);
      },
    );
  }

  Widget _makeCard(final int index) {
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        child: _makeListTile(_savingWithTransactionsList.elementAt(index)),
      ),
    );
  }

  Widget _makeListTile(SavingWithTransactions savingWithTransactions) {
    return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: const EdgeInsets.only(right: 12.0),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1.0, color: Colors.white24),
            ),
          ),
          child: const Icon(Icons.autorenew, color: Colors.white),
        ),
        title: Text(
          savingWithTransactions.saving.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            const Text(
              "Total: ",
              style: TextStyle(color: Colors.white),
            ),
            Text('RM${savingWithTransactions.saving.currentAmount}'),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_right,
            color: Colors.white, size: 30.0));
  }

  @override
  SavingsState getNewVersion() {
    return InLoadListSavingsState(version + 1, _savingWithTransactionsList);
  }

  @override
  SavingsState getStateCopy() {
    return InLoadListSavingsState(version, _savingWithTransactionsList);
  }
}
