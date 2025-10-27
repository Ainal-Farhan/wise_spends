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

class ListSavingsWidget extends StatelessWidget {
  final List<ListSavingVO> _listSavingVOList;

  const ListSavingsWidget({
    super.key,
    required List<ListSavingVO> listSavingVOList,
  }) : _listSavingVOList = listSavingVOList;

  @override
  Widget build(BuildContext context) {
    final savingsBloc = BlocProvider.of<SavingsBloc>(context);

    // Group savings by type
    final Map<SavingTableType, List<ListSavingVO>> savingGroupMap = {
      for (var t in SavingTableType.values) t: [],
    };

    for (final saving in _listSavingVOList) {
      final type = SavingTableType.findByValue(saving.saving.type);
      if (type != null) savingGroupMap[type]?.add(saving);
    }

    // If there are no savings, show empty state
    if (_listSavingVOList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'No savings yet',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Add your first savings account to get started',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Otherwise, build scrollable list
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Your Savings',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          ...savingGroupMap.entries
              .where((entry) => entry.value.isNotEmpty)
              .map((entry) => _buildSavingGroup(context, entry, savingsBloc)),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildSavingGroup(
    BuildContext context,
    MapEntry<SavingTableType, List<ListSavingVO>> entry,
    SavingsBloc bloc,
  ) {
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
          ...entry.value.map(
            (saving) => _buildSavingCard(context, bloc, saving),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingCard(
    BuildContext context,
    SavingsBloc bloc,
    ListSavingVO saving,
  ) {
    final isMinus = saving.saving.currentAmount < 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 25,
            child: const Icon(Icons.money, color: Colors.white),
          ),
          title: Text(
            saving.saving.name ?? 'Unnamed Saving',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (saving.moneyStorage != null)
                  Text(
                    'From: ${saving.moneyStorage!.shortName}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
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
          trailing: _buildPopupMenu(context, bloc, saving),
          onTap: () => bloc.add(LoadEditSavingsEvent(saving.saving.id)),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    SavingsBloc bloc,
    ListSavingVO saving,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
      onSelected: (String result) async {
        switch (result) {
          case 'edit':
            bloc.add(LoadEditSavingsEvent(saving.saving.id));
            break;
          case 'transaction':
            bloc.add(LoadSavingTransactionEvent(savingId: saving.saving.id));
            break;
          case 'delete':
            showDeleteDialog(
              context: context,
              onDelete: () async {
                await SingletonUtil.getSingleton<IManagerLocator>()!
                    .getSavingManager()
                    .deleteSelectedSaving(saving.saving.id);
                bloc.add(LoadListSavingsEvent());
              },
            );
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'transaction',
          child: Row(
            children: [
              Icon(Icons.attach_money, size: 18),
              SizedBox(width: 8),
              Text('View Transactions'),
            ],
          ),
        ),
        PopupMenuItem(
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
    );
  }
}
