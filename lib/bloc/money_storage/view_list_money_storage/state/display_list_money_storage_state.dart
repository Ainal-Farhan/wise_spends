import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/events/on_delete_view_list_money_storage_event.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/router/screen_argument.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_plus_button_round.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/money_storage/money_storage_vo.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class DisplayListMoneyStorageState extends IState<DisplayListMoneyStorageState> {
  final List<MoneyStorageVO> moneyStorageVOList;

  const DisplayListMoneyStorageState({
    required super.version,
    required this.moneyStorageVOList,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    List<ListTilesOneVO> moneyStorageListTilesOneVOList = [];

    for (int index = 0; index < moneyStorageVOList.length; index++) {
      bool isMinus =  moneyStorageVOList[index].amount < 0;
      moneyStorageListTilesOneVOList.add(
        ListTilesOneVO(
          index: index,
          title:
              '${moneyStorageVOList[index].moneyStorage.shortName} - ${moneyStorageVOList[index].moneyStorage.longName}',
          icon:
              const Icon(Icons.money, color: Color.fromARGB(255, 23, 194, 31)),
          subtitleWidget: Text(
            '${isMinus ? '- ' : ''}RM ${moneyStorageVOList[index].amount.abs().toStringAsFixed(2)}',
            style: TextStyle(color: isMinus ? Colors.red : Colors.black),
          ),
          onTap: () => Navigator.pushReplacementNamed(
            context,
            AppRouter.editMoneyStoragePageRoute,
            arguments: ScreenArgument({
              'moneyStorageId': moneyStorageVOList[index].moneyStorage.id,
            }),
          ),
          onLongPressed: () async {
            showDeleteDialog(
              context: context,
              onDelete: () async {
                ViewListMoneyStorageBloc()
                    .add(OnDeleteViewListMoneyStorageEvent(
                  moneyStorageVOList[index].moneyStorage.id,
                ));
              },
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: screenHeight * 0.8,
            child: IThListTilesOne(
              items: moneyStorageListTilesOneVOList,
              emptyListMessage: 'No Money Storage Available...',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IThPlusButtonRound(
                onTap: () => Navigator.pushReplacementNamed(
                  context,
                  AppRouter.addMoneyStoragePageRoute,
                ),
              ),
            ],
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
