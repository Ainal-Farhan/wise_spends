import 'package:flutter/material.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/list_tiles/th_list_tiles_one_default.dart';
import 'package:wise_spends/vo/impl/widgets/list_tiles/list_tiles_one_vo.dart';

abstract class IThListTilesOne extends IThWidget {
  factory IThListTilesOne({
    Key? key,
    required List<ListTilesOneVO> items,
    String emptyListMessage = 'The list is Empty',
    bool needBorder = false,
    String label = '',
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThListTilesOneDefault(
        items: items,
        emptyListMessage: emptyListMessage,
        label: label,
        needBorder: needBorder,
      );
    }
    return ThListTilesOneDefault(
      items: items,
      emptyListMessage: emptyListMessage,
      label: label,
      needBorder: needBorder,
    );
  }
}
