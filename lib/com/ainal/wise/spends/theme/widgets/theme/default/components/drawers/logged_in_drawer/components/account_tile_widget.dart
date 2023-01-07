import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/app/color_ref.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/account_button_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/txt.dart';

class AccountTileWidget extends StatelessWidget {
  final String name;
  final String position;

  const AccountTileWidget({
    required this.name,
    required this.position,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRef.complexDrawerBlueGrey,
      child: ListTile(
        leading: const AccountButtonWidget(usePadding: false),
        title: Txt(
          text: name,
          color: Colors.white,
        ),
        subtitle: Txt(
          text: position,
          color: Colors.white70,
        ),
      ),
    );
  }
}
