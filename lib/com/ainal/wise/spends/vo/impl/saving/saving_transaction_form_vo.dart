import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/i_vo.dart';

class SavingTransactionFormVO with IVO {
  SvngSaving? saving;

  double? transactionAmount;
  String? typeOfTransaction;
  double? maxTransactionOut;

  SavingTransactionFormVO({
    this.saving,
    this.transactionAmount,
    this.typeOfTransaction,
    required this.maxTransactionOut,
  });

  SavingTransactionFormVO.fromTableData(SvngSaving svg) {
    saving = svg;
    maxTransactionOut = svg.currentAmount;
    transactionAmount = .0;
    typeOfTransaction = '';
  }

  SavingTransactionFormVO.fromJson(Map<String, dynamic> json) {
    saving = SvngSaving.fromJson(json['saving']);
    transactionAmount = json['transactionAmount'];
    typeOfTransaction = json['typeOfTransaction'];
    maxTransactionOut = saving?.currentAmount ?? .0;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['savingId'] = saving?.toJson();
    data['transactionAmount'] = transactionAmount;
    data['typeOfTransaction'] = typeOfTransaction;
    return data;
  }
}
