import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/vo/i_vo.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

class CommitmentTaskVO extends IVO {
  String? commitmentTaskId;
  String? name;
  double? amount;
  bool? isDone;
  SavingVO? referredSavingVO;
  SvngMoneyStorage? moneyStorage;

  CommitmentTaskVO.fromExpnsCommitmentTask(ExpnsCommitmentTask task,
      SvngSaving saving, SvngMoneyStorage? svngMoneyStorage) {
    commitmentTaskId = task.id;
    name = task.name;
    amount = task.amount;
    referredSavingVO = SavingVO.fromSvngSaving(saving);
    moneyStorage = svngMoneyStorage;
  }

  CommitmentTaskVO.fromJson(Map<String, dynamic> data) {
    commitmentTaskId = data['commitmentTaskId'];
    name = data['name'];
    amount = data['amount'];
    referredSavingVO = SavingVO.fromJson(data['referredSavingVO']);
  }

  @override
  Map<String, dynamic> toJson() => {
        'commitmentTaskId': commitmentTaskId,
        'name': name,
        'amount': amount,
        'isDone': isDone,
        'referredSavingVO': referredSavingVO?.toJson() ?? {},
      };
}
