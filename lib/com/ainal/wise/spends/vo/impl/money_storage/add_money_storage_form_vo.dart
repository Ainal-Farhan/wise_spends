import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class AddMoneyStorageFormVO implements IVO {
  String? shortName;
  String? longName;
  String? type;

  AddMoneyStorageFormVO({
    this.shortName = '',
    this.longName = '',
    this.type = '',
  });

  AddMoneyStorageFormVO.fromJson(Map<String, dynamic> json) {
    shortName = json['shortName'];
    longName = json['longName'];
    type = json['type'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shortName'] = shortName;
    data['longName'] = longName;
    data['type'] = type;
    return data;
  }
}
