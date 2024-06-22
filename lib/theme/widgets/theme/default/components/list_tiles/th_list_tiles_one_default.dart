import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class ThListTilesOneDefault extends StatelessWidget implements IThListTilesOne {
  final List<ListTilesOneVO> items;
  final String emptyListMessage;

  const ThListTilesOneDefault({
    super.key,
    required this.items,
    required this.emptyListMessage,
  });

  @override
  Widget build(BuildContext context) {
    return items.isNotEmpty
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final ListTilesOneVO item = items[index];
              return Card(
                elevation: 8.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(64, 75, 96, .9),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.only(right: 12.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(width: 1.0, color: Colors.white24),
                        ),
                      ),
                      child: item.icon,
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: item.subtitleWidget,
                    trailing: item.trailingWidget,
                    onTap: () async => await item.onTap(),
                    onLongPress: () async => await item.onLongPressed(),
                  ),
                ),
              );
            },
          )
        : Center(
            child: Text(emptyListMessage),
          );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
