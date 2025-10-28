import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';

class CommitmentDetailVO extends IVO {
  String? commitmentDetailId;
  String? description;
  double? amount;
  String? type;
  SavingVO? referredSavingVO;

  CommitmentDetailVO();

  CommitmentDetailVO.fromExpnsCommitmentDetail(
      ExpnsCommitmentDetail commitmentDetail, SvngSaving? saving) {
    commitmentDetailId = commitmentDetail.id;
    description = commitmentDetail.description;
    amount = commitmentDetail.amount;
    type = commitmentDetail.type;
    if (saving != null) {
      referredSavingVO = SavingVO.fromSvngSaving(saving);
    }
  }

  CommitmentDetailVO.fromJson(Map<String, dynamic> json) {
    commitmentDetailId = json['commitmentDetailId'];
    description = json['description'];
    amount = json['amount'];
    type = json['type'];
    referredSavingVO = SavingVO.fromJson(json['referredSavingVO']);
  }

  @override
  Map<String, dynamic> toJson() => {
        'commitmentDetailId': commitmentDetailId,
        'description': description,
        'amount': amount,
        'type': type,
        'referredSavingVO': referredSavingVO?.toJson() ?? {},
      };
}
