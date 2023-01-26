import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class ListSavingVO implements IVO {
  final SvngSaving saving;
  SvngMoneyStorage? moneyStorage;

  ListSavingVO({
    required this.saving,
    this.moneyStorage,
  });

  ListSavingVO.fromJson(Map<String, dynamic> json)
      : saving = json['saving'],
        moneyStorage = json['moneyStorage'];

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['moneyStorage'] = moneyStorage?.toJson() ?? '';
    data['saving'] = saving.toJson();
    return data;
  }
}
