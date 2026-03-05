import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';

class CommitmentDetailVO extends IVO {
  String? commitmentDetailId;
  String? description;
  double? amount;
  String? type;
  // Added: savingId for linking a saving at creation time
  String? savingId;
  SavingVO? referredSavingVO;

  CommitmentDetailVO();

  CommitmentDetailVO.fromExpnsCommitmentDetail(
    ExpnsCommitmentDetail commitmentDetail,
    SvngSaving? saving,
  ) {
    commitmentDetailId = commitmentDetail.id;
    description = commitmentDetail.description;
    amount = commitmentDetail.amount;
    type = commitmentDetail.type;
    if (saving != null) {
      savingId = saving.id;
      referredSavingVO = SavingVO.fromSvngSaving(saving);
    }
  }

  CommitmentDetailVO.fromJson(Map<String, dynamic> json) {
    commitmentDetailId = json['commitmentDetailId'];
    description = json['description'];
    // FIX: Read as double, not dynamic
    amount = json['amount'] as double?;
    type = json['type'];
    savingId = json['savingId'];
    // FIX: Null-guard before parsing referredSavingVO
    referredSavingVO = json['referredSavingVO'] != null
        ? SavingVO.fromJson(json['referredSavingVO'] as Map<String, dynamic>)
        : null;
  }

  @override
  Map<String, dynamic> toJson() => {
    'commitmentDetailId': commitmentDetailId,
    'description': description,
    'amount': amount,
    'type': type,
    'savingId': savingId,
    // FIX: Emit null instead of {} when referredSavingVO is absent
    'referredSavingVO': referredSavingVO?.toJson(),
  };
}
