import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/money_storage/events/in_load_edit_money_storage_event.dart';
import 'package:wise_spends/bloc/impl/money_storage/events/in_load_add_money_storage_event.dart';
import 'package:wise_spends/bloc/impl/money_storage/events/on_delete_view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/vo/impl/money_storage/money_storage_vo.dart';

class DisplayListMoneyStorageState
    extends IState<DisplayListMoneyStorageState> {
  final List<MoneyStorageVO> moneyStorageVOList;

  const DisplayListMoneyStorageState({
    required super.version,
    required this.moneyStorageVOList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Your Money Storage',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: moneyStorageVOList.isNotEmpty
                ? ListView.builder(
                    itemCount: moneyStorageVOList.length,
                    itemBuilder: (context, index) {
                      final storage = moneyStorageVOList[index];
                      bool isMinus = storage.amount < 0;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
                                Icons.account_balance,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              storage.moneyStorage.shortName,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storage.moneyStorage.longName,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${isMinus ? '- ' : ''}RM ${storage.amount.abs().toStringAsFixed(2)}',
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
                              icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  BlocProvider.of<MoneyStorageBloc>(context)
                                      .add(InLoadEditMoneyStorageEvent(storage.moneyStorage.id));
                                }
                                if (result == 'delete') {
                                  showDeleteDialog(
                                    context: context,
                                    onDelete: () async {
                                      BlocProvider.of<MoneyStorageBloc>(context)
                                          .add(OnDeleteViewListMoneyStorageEvent(
                                        storage.moneyStorage.id,
                                      ));
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
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => BlocProvider.of<MoneyStorageBloc>(context)
                                .add(InLoadEditMoneyStorageEvent(storage.moneyStorage.id)),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'No money storage yet',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Add your first money storage to get started',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () => BlocProvider.of<MoneyStorageBloc>(context)
                  .add(InLoadAddMoneyStorageEvent()),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }



  @override
  DisplayListMoneyStorageState getNewVersion() => DisplayListMoneyStorageState(
        version: version + 1,
        moneyStorageVOList: [...moneyStorageVOList],
      );

  @override
  DisplayListMoneyStorageState getStateCopy() => DisplayListMoneyStorageState(
        version: version,
        moneyStorageVOList: [...moneyStorageVOList],
      );
}
