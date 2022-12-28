import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class AddSavingFormVO with IVO {
  String? savingName;
  double? currentAmount;

  AddSavingFormVO({this.savingName, this.currentAmount});

  AddSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingName = json['savingName'];
    currentAmount = json['currentAmount'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['savingName'] = savingName;
    data['currentAmount'] = currentAmount;
    return data;
  }
}
