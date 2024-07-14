import 'package:wise_spends/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/vo/i_vo.dart';

class SavingVO with IVO {
  String? savingName;
  double? currentAmount;
  double? goalAmount;
  bool? isHasGoal;
  String? moneyStorageId;
  SavingTableType? savingTableType;
  String? savingId;

  SavingVO({
    this.savingName,
    this.currentAmount,
    this.goalAmount,
    this.isHasGoal,
    this.moneyStorageId,
    this.savingTableType,
    this.savingId,
  });

  SavingVO.fromSvngSaving(SvngSaving saving) {
    savingId = saving.id;
    savingName = saving.name;
    currentAmount = saving.currentAmount;
    goalAmount = saving.goal;
    isHasGoal = saving.isHasGoal;
    moneyStorageId = saving.moneyStorageId;
    savingTableType = SavingTableType.findByValue(saving.type);
  }

  SavingVO.fromJson(Map<String, dynamic> json) {
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
