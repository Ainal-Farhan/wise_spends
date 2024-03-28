import 'package:wise_spends/vo/i_vo.dart';

class AddSavingFormVO with IVO {
  String? savingName;
  double? currentAmount;
  double? goalAmount;
  bool? isHasGoal;
  String? moneyStorageId;

  AddSavingFormVO({
    this.savingName,
    this.currentAmount,
    this.goalAmount,
    this.isHasGoal,
    this.moneyStorageId,
  });

  AddSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingName = json['savingName'];
    currentAmount = json['currentAmount'];
    goalAmount = json['goalAmount'];
    isHasGoal = json['isHasGoal'];
    moneyStorageId = json['moneyStorageId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['savingName'] = savingName;
    data['currentAmount'] = currentAmount;
    data['goalAmount'] = goalAmount;
    data['isHasGoal'] = isHasGoal;
    data['moneyStorageId'] = moneyStorageId;
    return data;
  }
}
