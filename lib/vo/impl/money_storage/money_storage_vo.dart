import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/vo/i_vo.dart';

class MoneyStorageVO implements IVO {
  late final SvngMoneyStorage moneyStorage;
  late final double amount;

  MoneyStorageVO({
    required this.moneyStorage,
    required this.amount,
  });

  MoneyStorageVO.fromJson(Map<String, dynamic> json) {
    moneyStorage = SvngMoneyStorage.fromJson(json['moneyStorage']);
    amount = json['amount'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['moneyStorage'] = moneyStorage.toJson();
    data['amount'] = amount;
    return data;
  }
}
