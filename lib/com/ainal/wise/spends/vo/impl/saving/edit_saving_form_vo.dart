import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class EditSavingFormVO implements IVO {
  late String savingId;
  late String savingName;
  late double currentAmount;
  late double goalAmount;
  late bool isHasGoal;
  late String moneyStorageId;

  EditSavingFormVO({
    required this.savingId,
    required this.savingName,
    required this.currentAmount,
    required this.goalAmount,
    required this.isHasGoal,
    required this.moneyStorageId,
  });

  EditSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingId = json['savingId'];
    savingName = json['savingName'];
    currentAmount = json['currentAmount'];
    goalAmount = json['goalAmount'];
    isHasGoal = json['isHasGoal'];
    moneyStorageId = json['moneyStorageId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['savingId'] = savingId;
    data['savingName'] = savingName;
    data['currentAmount'] = currentAmount;
    data['goalAmount'] = goalAmount;
    data['isHasGoal'] = isHasGoal;
    data['moneyStorageId'] = moneyStorageId;
    return data;
  }
}
