import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';

class CommitmentVO extends IVO {
  String? commitmentId;
  String? name;
  String? description;
  double? totalAmount;
  String? frequency;
  SavingVO? referredSavingVO;
  List<CommitmentDetailVO> commitmentDetailVOList = [];

  CommitmentVO();

  CommitmentVO.fromExpnsCommitment(
    ExpnsCommitment commitment,
    Map<ExpnsCommitmentDetail, SvngSaving> commitmentDetailMap,
  ) {
    commitmentId = commitment.id;
    name = commitment.name;
    description = commitment.description;
    totalAmount = 0.0;
    for (final entry in commitmentDetailMap.entries) {
      totalAmount = totalAmount! + entry.key.amount;
      commitmentDetailVOList.add(
        CommitmentDetailVO.fromExpnsCommitmentDetail(entry.key, entry.value),
      );
    }
  }

  CommitmentVO.fromJson(Map<String, dynamic> json) {
    commitmentId = json['commitmentId'];
    name = json['name'];
    description = json['description'];
    // FIX: Read as double, not String
    totalAmount = json['totalAmount'] as double?;
    frequency = json['frequency'];
    // FIX: Null-guard before parsing referredSavingVO
    referredSavingVO = json['referredSavingVO'] != null
        ? SavingVO.fromJson(json['referredSavingVO'] as Map<String, dynamic>)
        : null;
    // FIX: Null-safe cast with fallback to empty list
    commitmentDetailVOList = (json['commitmentDetailVOList'] as List? ?? [])
        .map(
          (detail) =>
              CommitmentDetailVO.fromJson(detail as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'commitmentId': commitmentId,
      // FIX: Keep native types, don't stringify with '$'
      'name': name,
      'description': description,
      'totalAmount': totalAmount,
      'frequency': frequency,
      // FIX: Emit null instead of {} when absent
      'referredSavingVO': referredSavingVO?.toJson(),
      // FIX: Added () to actually call toList
      'commitmentDetailVOList': commitmentDetailVOList
          .map((detail) => detail.toJson())
          .toList(),
    };
  }
}
