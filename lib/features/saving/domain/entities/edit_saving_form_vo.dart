import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';

class EditSavingFormVO implements IVO {
  late String savingId;
  late String savingName;
  late double currentAmount;
  late double goalAmount;
  late bool isHasGoal;
  late String moneyStorageId;
  late String savingType;
  String? categoryId;

  EditSavingFormVO({
    required this.savingId,
    required this.savingName,
    required this.currentAmount,
    required this.goalAmount,
    required this.isHasGoal,
    required this.moneyStorageId,
    required this.savingType,
    this.categoryId,
  });

  EditSavingFormVO.fromJson(Map<String, dynamic> json) {
    savingId = json['savingId'];
    savingName = json['savingName'];
    currentAmount = json['currentAmount'];
    goalAmount = json['goalAmount'];
    isHasGoal = json['isHasGoal'];
    moneyStorageId = json['moneyStorageId'];
    categoryId = json['categoryId'];
    String? savingTableTypeValue = json['savingTableType'];
    savingType = savingTableTypeValue != null
        ? SavingTableType.normalizeInput(savingTableTypeValue)
        : SavingTableType.saving.value;
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
    data['savingTableType'] = savingType;
    if (categoryId != null) {
      data['categoryId'] = categoryId;
    }
    return data;
  }
}
