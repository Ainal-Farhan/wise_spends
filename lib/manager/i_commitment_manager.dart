import 'package:wise_spends/manager/i_manager.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_details_vo.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_vo.dart';

abstract class ICommitmentManager extends IManager {
  Future<List<CommitmentVO>> retrieveListOfCommitmentOfCurrentUser();

  Future<void> saveCommitmentVO(CommitmentVO commitmentVO);

  Future<void> saveCommitmentDetailVO(
      String commitmentId, List<CommitmentDetailVO> commitmentDetailVOList);
}
