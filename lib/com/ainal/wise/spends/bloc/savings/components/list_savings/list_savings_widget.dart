import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as route;

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
          ISavingManager savingManager = SavingManager();
          await savingManager
              .deleteSelectedSaving(savingWithTransactions.saving.id);
          Navigator.pushReplacementNamed(context, route.savingsPageRoute);
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
      trailing: const Icon(
        Icons.keyboard_arrow_right,
        color: Colors.white,
        size: 30.0,
      ),
    );
  }
}
