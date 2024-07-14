import 'package:wise_spends/vo/i_vo.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_details_vo.dart';
import 'package:wise_spends/vo/impl/saving/saving_vo.dart';

class CommitmentVO extends IVO {
  String? commitmentId;
  String? name;
  String? description;
  double? totalAmount;
  SavingVO? referredSavingVO;
  List<CommitmentDetailVO> commitmentDetailVOList = [];

  CommitmentVO();

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
