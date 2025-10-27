import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_edit_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_saving_transaction_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';

// Enhanced card widget for savings is not needed since we're using a direct approach in the build method

class ListSavingsWidget extends StatelessWidget {
  final List<ListSavingVO> _listSavingVOList;

  const ListSavingsWidget(
      {super.key, required List<ListSavingVO> listSavingVOList})
      : _listSavingVOList = listSavingVOList;

  @override
  Widget build(BuildContext context) {
    final savingsBloc = BlocProvider.of<SavingsBloc>(context);

    // Group savings by type
    Map<SavingTableType, List<ListSavingVO>> savingGroupMap = {};
    for (SavingTableType savingType in SavingTableType.values) {
      savingGroupMap[savingType] = [];
    }

    for (int index = 0; index < _listSavingVOList.length; index++) {
      SavingTableType? type =
          SavingTableType.findByValue(_listSavingVOList[index].saving.type);
      if (type != null) {
        savingGroupMap[type]?.add(_listSavingVOList[index]);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Your Savings',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...savingGroupMap.entries.map((entry) {
            final savingsOfType = entry.value;
            if (savingsOfType.isEmpty) return Container();

            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      entry.key.label,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ...savingsOfType.asMap().entries.map((entry) {
                    final saving = entry.value;
                    bool isMinus = saving.saving.currentAmount < 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            child: const Icon(
                              Icons.money,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            saving.saving.name ?? 'Unnamed Saving',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (saving.moneyStorage != null)
                                  Text(
                                    'From: ${saving.moneyStorage!.shortName}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.0,
                                    ),
                                  ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '${isMinus ? '- ' : ''}RM ${saving.saving.currentAmount.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: isMinus ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                color: Theme.of(context).primaryColor),
                            onSelected: (String result) {
                              if (result == 'edit') {
                                BlocProvider.of<SavingsBloc>(context).add(
                                    LoadEditSavingsEvent(saving.saving.id));
                              }
                              if (result == 'transaction') {
                                BlocProvider.of<SavingsBloc>(context).add(
                                    LoadSavingTransactionEvent(
                                        savingId: saving.saving.id));
                              }
                              if (result == 'delete') {
                                showDeleteDialog(
                                  context: context,
                                  onDelete: () async {
                                    await SingletonUtil.getSingleton<
                                            IManagerLocator>()!
                                        .getSavingManager()
                                        .deleteSelectedSaving(saving.saving.id);
                                    savingsBloc.add(LoadListSavingsEvent());
                                  },
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'transaction',
                                child: Row(
                                  children: [
                                    Icon(Icons.attach_money, size: 18),
                                    SizedBox(width: 8),
                                    Text('View Transactions'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => BlocProvider.of<SavingsBloc>(context)
                              .add(LoadEditSavingsEvent(saving.saving.id)),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          if (_listSavingVOList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'No savings yet',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Add your first savings account to get started',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
