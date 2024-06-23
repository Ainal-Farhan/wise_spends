import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/savings/event/load_saving_transaction_event.dart';
import 'package:wise_spends/bloc/savings/index.dart';
import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/manager/i_saving_manager.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/router/screen_argument.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class ListSavingsWidget extends StatelessWidget {
  final List<ListSavingVO> _listSavingVOList;

  const ListSavingsWidget(
      {super.key, required List<ListSavingVO> listSavingVOList})
      : _listSavingVOList = listSavingVOList;

  @override
  Widget build(BuildContext context) {
    Map<SavingTableType, List<ListTilesOneVO>> savingListMap = {};

    for (SavingTableType savingTableType in SavingTableType.values) {
      savingListMap[savingTableType] = [];
    }

    for (int index = 0; index < _listSavingVOList.length; index++) {
      bool isMinus = _listSavingVOList[index].saving.currentAmount < 0;

      savingListMap[SavingTableType.findByValue(
              _listSavingVOList[index].saving.type)]!
          .add(
        ListTilesOneVO(
          index: index,
          title: _listSavingVOList[index].saving.name ?? '',
          icon:
              const Icon(Icons.money, color: Color.fromARGB(255, 23, 194, 31)),
          subtitleWidget: Row(
            children: <Widget>[
              Text(
                _listSavingVOList[index].moneyStorage != null
                    ? '${_listSavingVOList[index].moneyStorage!.shortName}: '
                    : ': ',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                '${isMinus ? '- ' : ''}RM ${_listSavingVOList[index].saving.currentAmount.abs().toStringAsFixed(2)}',
                style: TextStyle(color: isMinus ? Colors.red : Colors.black),
              ),
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

    List<Widget> listViewWidget = [];
    final double screenHeight = MediaQuery.of(context).size.height;

    listViewWidget.add(SizedBox(
      height: screenHeight * 0.05,
    ));

    for (var entry in savingListMap.entries) {
      listViewWidget.add(IThListTilesOne(
        items: entry.value,
        needBorder: true,
        label: entry.key.label,
        emptyListMessage: 'No Savings Added',
      ));
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listViewWidget,
      ),
    );
  }
}
