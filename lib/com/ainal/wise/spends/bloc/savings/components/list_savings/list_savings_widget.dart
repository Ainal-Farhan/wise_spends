import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_saving_transaction_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/screen_argument.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class ListSavingsWidget extends StatelessWidget {
  final List<SavingWithTransactions> _savingWithTransactionsList;

  const ListSavingsWidget(
      {key, required List<SavingWithTransactions> savingWithTransactionsList})
      : _savingWithTransactionsList = savingWithTransactionsList,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ListTilesOneVO> savingsList = [];

    for (int index = 0; index < _savingWithTransactionsList.length; index++) {
      savingsList.add(
        ListTilesOneVO(
          index: index,
          title: _savingWithTransactionsList[index].saving.name ?? '',
          icon: const Icon(Icons.money, color: Colors.white),
          subtitleWidget: Row(
            children: <Widget>[
              const Text(
                "Total: ",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                  'RM${_savingWithTransactionsList[index].saving.currentAmount.toStringAsFixed(2)}'),
            ],
          ),
          trailingWidget: IconButton(
            onPressed: () => SavingsBloc().add(LoadSavingTransactionEvent(
                savingId: _savingWithTransactionsList[index].saving.id)),
            icon: const Icon(Icons.attach_money_outlined),
          ),
          onTap: () async => Navigator.pushReplacementNamed(
            context,
            AppRouter.editSavingsPageRoute,
            arguments: ScreenArgument({
              'savingId': _savingWithTransactionsList[index].saving.id,
            }),
          ),
          onLongPressed: () async {
            showDeleteDialog(
              context: context,
              onDelete: () async {
                await ISavingManager().deleteSelectedSaving(
                    _savingWithTransactionsList[index].saving.id);
                SavingsBloc().add(LoadListSavingsEvent());
              },
            );
          },
        ),
      );
    }

    return IThListTilesOne(items: savingsList);
  }
}
