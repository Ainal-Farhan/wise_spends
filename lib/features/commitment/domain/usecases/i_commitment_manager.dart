import 'package:wise_spends/domain/usecases/i_manager.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_detail_vo.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_vo.dart';

abstract class ICommitmentManager extends IManager {
  Future<List<CommitmentVO>> retrieveListOfCommitmentOfCurrentUser();

  Future<CommitmentVO?> retrieveCommitmentVOBasedOnCommitmentId(
    String commitmentId,
  );

  Future<void> saveCommitmentVO(CommitmentVO commitmentVO);

  Future<void> deleteCommitmentVO(String commitmentId);

  Future<void> deleteCommitmentDetailVO(String commitmentDetailId);

  Future<void> saveCommitmentDetailVO(
    String commitmentId,
    List<CommitmentDetailVO> commitmentDetailVOList,
  );

  Stream<int> retrieveTotalCommitmentTask();

  Future<String> startDistributeCommitment(CommitmentVO vo);

  Future<List<CommitmentTaskVO>> retrieveListOfCommitmentTask(
    bool isDone, {
    int? limit,
    int? offset,
  });

  Future<void> updateStatusCommitmentTask(bool isDone, CommitmentTaskVO taskVO);

  Future<void> addCommitmentTask(CommitmentTaskVO taskVO);

  Future<void> editCommitmentTask(CommitmentTaskVO taskVO);

  Future<void> deleteCommitmentTask(CommitmentTaskVO taskVO);
}
