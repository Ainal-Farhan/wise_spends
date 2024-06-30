import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_edit_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_saving_transaction_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class ListSavingsWidget extends StatelessWidget {
  final List<ListSavingVO> _listSavingVOList;

  const ListSavingsWidget(
      {super.key, required List<ListSavingVO> listSavingVOList})
      : _listSavingVOList = listSavingVOList;

  @override
  Widget build(BuildContext context) {
    final savingsBloc = BlocProvider.of<SavingsBloc>(context);
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
          subtitleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _listSavingVOList[index].moneyStorage != null
                    ? _listSavingVOList[index].moneyStorage!.shortName
                    : '',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                '${isMinus ? '- ' : ''}RM ${_listSavingVOList[index].saving.currentAmount.abs().toStringAsFixed(2)}',
                style: TextStyle(color: isMinus ? Colors.red : Colors.black),
              ),
            ],
          ),
          trailingWidget: IconButton(
            onPressed: () => BlocProvider.of<SavingsBloc>(context).add(
                LoadSavingTransactionEvent(
                    savingId: _listSavingVOList[index].saving.id)),
            icon: const Icon(Icons.attach_money_outlined),
          ),
          onTap: () async => BlocProvider.of<SavingsBloc>(context)
              .add(LoadEditSavingsEvent(_listSavingVOList[index].saving.id)),
          onLongPressed: () async {
            showDeleteDialog(
              context: context,
              onDelete: () async {
                await SingletonUtil.getSingleton<IManagerLocator>()!
                    .getSavingManager()
                    .deleteSelectedSaving(_listSavingVOList[index].saving.id);
                savingsBloc.add(LoadListSavingsEvent());
              },
            );
          },
        ),
      );
    }

    List<Widget> listViewWidget = [];
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    listViewWidget.add(SizedBox(
      height: screenHeight * 0.05,
    ));

    List<Widget> listSavingsWidget = [];
    for (var entry in savingListMap.entries) {
      listSavingsWidget.add(IThListTilesOne(
        maxWidth: screenWidth * 0.88,
        maxHeight: screenHeight * 0.70,
        items: entry.value,
        needBorder: true,
        label: entry.key.label,
        emptyListMessage: 'No Savings Added',
      ));
    }

    listViewWidget.add(
      SizedBox(
        height: screenHeight * 0.85,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: listSavingsWidget.length,
            itemBuilder: (BuildContext context, int index) {
              return listSavingsWidget[index];
            },
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listViewWidget,
      ),
    );
  }
}
