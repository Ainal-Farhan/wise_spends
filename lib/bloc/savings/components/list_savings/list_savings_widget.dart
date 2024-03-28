import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/bloc/savings/event/impl/load_saving_transaction_event.dart';
import 'package:wise_spends/bloc/savings/index.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/router/screen_argument.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class ListSavingsWidget extends StatelessWidget {
  final List<ListSavingVO> _listSavingVOList;

  const ListSavingsWidget({key, required List<ListSavingVO> listSavingVOList})
      : _listSavingVOList = listSavingVOList,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ListTilesOneVO> savingsList = [];

    for (int index = 0; index < _listSavingVOList.length; index++) {
      savingsList.add(
        ListTilesOneVO(
          index: index,
          title: _listSavingVOList[index].saving.name ?? '',
          icon: const Icon(Icons.money, color: Colors.white),
          subtitleWidget: Row(
            children: <Widget>[
              Text(
                _listSavingVOList[index].moneyStorage != null
                    ? '${_listSavingVOList[index].moneyStorage!.shortName}: '
                    : ': ',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                  'RM${_listSavingVOList[index].saving.currentAmount.toStringAsFixed(2)}'),
            ],
          ),
          trailingWidget: IconButton(
            onPressed: () => SavingsBloc().add(LoadSavingTransactionEvent(
                savingId: _listSavingVOList[index].saving.id)),
            icon: const Icon(Icons.attach_money_outlined),
          ),
          onTap: () async => Navigator.pushReplacementNamed(
            context,
            AppRouter.editSavingsPageRoute,
            arguments: ScreenArgument({
              'savingId': _listSavingVOList[index].saving.id,
            }),
          ),
          onLongPressed: () async {
            showDeleteDialog(
              context: context,
              onDelete: () async {
                await ISavingManager()
                    .deleteSelectedSaving(_listSavingVOList[index].saving.id);
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
