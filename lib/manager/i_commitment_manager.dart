import 'package:wise_spends/manager/i_manager.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

abstract class ICommitmentManager extends IManager {
  Future<List<CommitmentVO>> retrieveListOfCommitmentOfCurrentUser();

  Future<CommitmentVO?> retrieveCommitmentVOBasedOnCommitmentId(
      String commitmentId);

  Future<void> saveCommitmentVO(CommitmentVO commitmentVO);

  Future<void> deleteCommitmentVO(String commitmentId);

  Future<void> deleteCommitmentDetailVO(String commitmentDetailId);

  Future<void> saveCommitmentDetailVO(
      String commitmentId, List<CommitmentDetailVO> commitmentDetailVOList);
}
