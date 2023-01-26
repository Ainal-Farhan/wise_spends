import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/events/impl/on_delete_view_list_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/money_storage/money_storage_vo.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class DisplayListMoneyStorageState extends ViewListMoneyStorageState {
  final List<MoneyStorageVO> moneyStorageVOList;

  const DisplayListMoneyStorageState({
    required int version,
    required this.moneyStorageVOList,
  }) : super(version: version);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    List<ListTilesOneVO> moneyStorageListTilesOneVOList = [];

    for (int index = 0; index < moneyStorageVOList.length; index++) {
      moneyStorageListTilesOneVOList.add(
        ListTilesOneVO(
          index: index,
          title: moneyStorageVOList[index].moneyStorage.shortName,
          icon: const Icon(Icons.money, color: Colors.white),
          subtitleWidget: Row(
            children: <Widget>[
              const Text(
                "Total: ",
                style: TextStyle(color: Colors.white),
              ),
              Text('RM${moneyStorageVOList[index].amount.toStringAsFixed(2)}'),
            ],
          ),
          trailingWidget: IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.attach_money_outlined),
          ),
          onTap: () async => {},
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
              Ink(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(400.0),
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRouter.addMoneyStoragePageRoute,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add,
                      size: 30.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  ViewListMoneyStorageState getNewVersion() => DisplayListMoneyStorageState(
        version: version + 1,
        moneyStorageVOList: [...moneyStorageVOList],
      );

  @override
  ViewListMoneyStorageState getStateCopy() => DisplayListMoneyStorageState(
        version: version,
        moneyStorageVOList: [...moneyStorageVOList],
      );
}
