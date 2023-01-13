import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class AddSavingFormVO with IVO {
  String? savingName;
  double? currentAmount;
  double? goalAmount;
  bool? isHasGoal;

  AddSavingFormVO({
    this.savingName,
    this.currentAmount,
    this.goalAmount,
    this.isHasGoal,
  });

  AddSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingName = json['savingName'];
    currentAmount = json['currentAmount'];
    goalAmount = json['goalAmount'];
    isHasGoal = json['isHasGoal'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['savingName'] = savingName;
    data['currentAmount'] = currentAmount;
    data['goalAmount'] = goalAmount;
    data['isHasGoal'] = isHasGoal;
    return data;
  }
}
