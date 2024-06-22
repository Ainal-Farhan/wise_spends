import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/vo/i_vo.dart';

class AddSavingFormVO with IVO {
  String? savingName;
  double? currentAmount;
  double? goalAmount;
  bool? isHasGoal;
  String? moneyStorageId;
  SavingTableType? savingTableType;

  AddSavingFormVO({
    this.savingName,
    this.currentAmount,
    this.goalAmount,
    this.isHasGoal,
    this.moneyStorageId,
    this.savingTableType,
  });

  AddSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingName = json['savingName'];
    currentAmount = json['currentAmount'];
    goalAmount = json['goalAmount'];
    isHasGoal = json['isHasGoal'];
    moneyStorageId = json['moneyStorageId'];
    String? savingTableTypeValue = json['savingTableType'];

    if (savingTableTypeValue != null) {
      savingTableType = SavingTableType.findByValue(savingTableTypeValue);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['savingName'] = savingName;
    data['currentAmount'] = currentAmount;
    data['goalAmount'] = goalAmount;
    data['isHasGoal'] = isHasGoal;
    data['moneyStorageId'] = moneyStorageId;
    if (savingTableType != null) {
      data['savingTableType'] = savingTableType!.value;
    }
    return data;
  }
}
