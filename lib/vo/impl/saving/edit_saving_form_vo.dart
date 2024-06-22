import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/vo/i_vo.dart';

class EditSavingFormVO implements IVO {
  late String savingId;
  late String savingName;
  late double currentAmount;
  late double goalAmount;
  late bool isHasGoal;
  late String moneyStorageId;
  SavingTableType? savingTableType;


  EditSavingFormVO({
    required this.savingId,
    required this.savingName,
    required this.currentAmount,
    required this.goalAmount,
    required this.isHasGoal,
    required this.moneyStorageId,
    required this.savingTableType,
  });

  EditSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingId = json['savingId'];
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
    data['savingId'] = savingId;
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
