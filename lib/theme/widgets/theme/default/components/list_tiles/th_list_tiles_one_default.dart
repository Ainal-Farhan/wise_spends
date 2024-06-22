import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

class ThListTilesOneDefault extends StatelessWidget implements IThListTilesOne {
  final List<ListTilesOneVO> items;
  final String emptyListMessage;
  final bool needBorder;
  final String label;

  const ThListTilesOneDefault({
    super.key,
    required this.items,
    required this.emptyListMessage,
    required this.needBorder,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    ListView listView = ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final ListTilesOneVO item = items[index];
        return Card(
          elevation: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(226, 68, 185, 214),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
    );

    return needBorder
        ? Stack(
            children: [
              Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 245, 245, 245)
                            .withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: items.isNotEmpty
                      ? listView
                      : Center(
                          child: Text(emptyListMessage),
                        )),
              Positioned(
                top: -16,
                left: 12,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color:
                      const Color.fromARGB(255, 226, 226, 226).withOpacity(0.9),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        : listView;
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
