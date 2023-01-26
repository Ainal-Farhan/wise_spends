import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class EditMoneyStorageFormVO implements IVO {
  String? id;
  String? shortName;
  String? longName;
  String? type;

  EditMoneyStorageFormVO({
    required this.id,
    required this.shortName,
    required this.longName,
    required this.type,
  });

  EditMoneyStorageFormVO.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shortName = json['shortName'];
    longName = json['longName'];
    type = json['type'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['shortName'] = shortName;
    data['longName'] = longName;
    data['type'] = type;
    return data;
  }
}
