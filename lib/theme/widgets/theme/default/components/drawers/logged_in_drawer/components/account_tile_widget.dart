import 'package:flutter/material.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/account_button_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/txt.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class AccountTileWidget extends StatelessWidget {
  final String name;
  final String position;

  const AccountTileWidget({
    required this.name,
    required this.position,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SingletonUtil.getSingleton<IManagerLocator>()!
          .getThemeManager()
          .colorTheme
          .complexDrawerBlueGrey,
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
