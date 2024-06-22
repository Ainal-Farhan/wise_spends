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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(226, 68, 185, 214),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.white,
                      ),
                      child: item.icon,
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: item.subtitleWidget,
                    ),
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
