import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class ListTilesOneVO extends IVO {
  final String title;
  final Widget icon;
  final Future Function() onLongPressed;
  final Future Function() onTap;
  final Widget subtitleWidget;
  final Widget? trailingWidget;
  final int index;

  ListTilesOneVO({
    required this.title,
    required this.icon,
    required this.subtitleWidget,
    required this.onTap,
    required this.onLongPressed,
    this.trailingWidget,
    required this.index,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    data['title'] = title;
    data['icon'] = icon;
    data['subtitleWidget'] = subtitleWidget;
    data['onTap'] = onTap;
    data['onLongPressed'] = onLongPressed;
    data['trailingWidget'] = trailingWidget;
    return data;
  }
}
