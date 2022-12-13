import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class AddSavingFormVO with IVO {
  String? savingName;

  AddSavingFormVO({this.savingName});

  AddSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingName = json['savingName'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['savingName'] = savingName;
    return data;
  }
}
