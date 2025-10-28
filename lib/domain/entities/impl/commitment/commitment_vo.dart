import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/i_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';

class CommitmentVO extends IVO {
  String? commitmentId;
  String? name;
  String? description;
  double? totalAmount;
  SavingVO? referredSavingVO;
  List<CommitmentDetailVO> commitmentDetailVOList = [];

  CommitmentVO();

  CommitmentVO.fromExpnsCommitment(ExpnsCommitment commitment,
      Map<ExpnsCommitmentDetail, SvngSaving> commitmentDetailMap) {
    commitmentId = commitment.id;
    name = commitment.name;
    description = commitment.description;
    totalAmount = .0;
    for (MapEntry<ExpnsCommitmentDetail, SvngSaving> entry
        in commitmentDetailMap.entries) {
      totalAmount = totalAmount! + entry.key.amount;

      commitmentDetailVOList.add(
          CommitmentDetailVO.fromExpnsCommitmentDetail(entry.key, entry.value));
    }
  }

  CommitmentVO.fromJson(Map<String, dynamic> json) {
    commitmentId = json['commitmentId'];
    name = json['name'];
    description = json['description'];
    totalAmount = json['totalAmount'];
    referredSavingVO = SavingVO.fromJson(json['referredSavingVO']);
    commitmentDetailVOList = (json['commitmentDetailVOList'] as List)
        .map((detail) => CommitmentDetailVO.fromJson(detail))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'commitmentId': commitmentId,
      'name': '$name',
      'description': '$description',
      'totalAmount': '$totalAmount',
      'referredSavingVO': referredSavingVO?.toJson() ?? {},
      'commitmentDetailVOList':
          commitmentDetailVOList.map((detail) => detail.toJson()).toList,
    };
  }
}
