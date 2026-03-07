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
        CommitmentDetailVO.fromExpnsCommitmentDetail(
          entry.key,
          saving: entry.value,
        ),
      );
    }
  }

  /// Constructs a CommitmentVO from an already-resolved list of
  /// [CommitmentDetailVO] objects (source saving + target saving + payee
  /// all hydrated). Use this from CommitmentManager after the detail join
  /// loop so we never pass a Map that can only carry one saving per detail.
  CommitmentVO.fromExpnsCommitmentWithDetails(
    ExpnsCommitment commitment,
    List<CommitmentDetailVO> details,
  ) {
    commitmentId = commitment.id;
    name = commitment.name;
    description = commitment.description;
    commitmentDetailVOList = details;
    totalAmount = details.fold(
      0.0,
      (sum, d) => (sum ?? .0) + (d.amount ?? 0.0),
    );
  }

  CommitmentVO.fromJson(Map<String, dynamic> json) {
    commitmentId = json['commitmentId'];
    name = json['name'];
    description = json['description'];
    totalAmount = json['totalAmount'] as double?;
    frequency = json['frequency'];
    referredSavingVO = json['referredSavingVO'] != null
        ? SavingVO.fromJson(json['referredSavingVO'] as Map<String, dynamic>)
        : null;
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
      'name': name,
      'description': description,
      'totalAmount': totalAmount,
      'frequency': frequency,
      'referredSavingVO': referredSavingVO?.toJson(),
      'commitmentDetailVOList': commitmentDetailVOList
          .map((detail) => detail.toJson())
          .toList(),
    };
  }
}
