import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_detail_type.dart';

class CommitmentDetailVO extends IVO {
  String? commitmentDetailId;
  String? description;
  double? amount;
  CommitmentDetailType? type;
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
    amount = json['amount'] as double?;
    
    // Parse enum from string
    final typeString = json['type'] as String?;
    type = typeString != null
        ? CommitmentDetailType.values.firstWhere(
            (e) => e.name == typeString,
            orElse: () => CommitmentDetailType.monthly,
          )
        : null;
    
    savingId = json['savingId'];
    referredSavingVO = json['referredSavingVO'] != null
        ? SavingVO.fromJson(json['referredSavingVO'] as Map<String, dynamic>)
        : null;
  }

  @override
  Map<String, dynamic> toJson() => {
    'commitmentDetailId': commitmentDetailId,
    'description': description,
    'amount': amount,
    'type': type?.name,
    'savingId': savingId,
    'referredSavingVO': referredSavingVO?.toJson(),
  };
}
