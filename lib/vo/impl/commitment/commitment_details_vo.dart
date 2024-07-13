import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/vo/i_vo.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

class CommitmentDetailVO extends IVO {
  String? description;
  double? amount;
  String? type;
  SavingVO? referredSavingVO;

  CommitmentDetailVO.fromExpnsCommitmentDetail(
      ExpnsCommitmentDetail commitmentDetail, SvngSaving? saving) {
    description = commitmentDetail.description;
    amount = commitmentDetail.amount;
    type = commitmentDetail.type;
    if (saving != null) {
      referredSavingVO = SavingVO.fromSvngSaving(saving);
    }
  }

  CommitmentDetailVO.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    amount = json['amount'];
    type = json['type'];
    referredSavingVO = SavingVO.fromJson(json['referredSavingVO']);
  }

  @override
  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'type': type,
        'referredSavingVO': referredSavingVO?.toJson() ?? {},
      };
}
