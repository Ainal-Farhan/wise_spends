import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_saving_transaction_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/ui/alert_dialog/delete_dialog.dart';

// ignore: must_be_immutable
class ListSavingsWidget extends StatelessWidget {
  final List<SavingWithTransactions> _savingWithTransactionsList;

  Function _onLongPressed = (SavingWithTransactions savingWithTransactions) {};

  ListSavingsWidget(
      {key, required List<SavingWithTransactions> savingWithTransactionsList})
      : _savingWithTransactionsList = savingWithTransactionsList,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final int listLength = _savingWithTransactionsList.length;
    _onLongPressed = (SavingWithTransactions savingWithTransactions) async {
      showDeleteDialog(
        context: context,
        onDelete: () async {
          ISavingManager savingManager = ISavingManager();
          await savingManager
              .deleteSelectedSaving(savingWithTransactions.saving.id);
          SavingsBloc().add(LoadListSavingsEvent());
        },
      );
    };

    return listLength > 0
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: listLength,
            itemBuilder: (BuildContext context, int index) {
              return _makeCard(index);
            },
          )
        : const Center(
            child: Text('There is no saving available'),
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
      onLongPress: () => _onLongPressed(savingWithTransactions),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: const EdgeInsets.only(right: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(width: 1.0, color: Colors.white24),
          ),
        ),
        child: const Icon(Icons.money, color: Colors.white),
      ),
      title: Text(
        savingWithTransactions.saving.name ?? '-',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: <Widget>[
          const Text(
            "Total: ",
            style: TextStyle(color: Colors.white),
          ),
          Text(
              'RM${savingWithTransactions.saving.currentAmount.toStringAsFixed(2)}'),
        ],
      ),
      onTap: () => SavingsBloc().add(LoadSavingTransactionEvent(
          savingId: savingWithTransactions.saving.id)),
    );
  }
}
