import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/expense/index.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';

abstract class ICommitmentTaskRepository
    extends
        ICrudRepository<
          CommitmentTaskTable,
          $CommitmentTaskTableTable,
          CommitmentTaskTableCompanion,
          ExpnsCommitmentTask
        > {
  ICommitmentTaskRepository(AppDatabase db) : super(db, db.commitmentTaskTable);

  Stream<List<ExpnsCommitmentTask>> watchAll(bool isDone);

  Future<List<CommitmentTaskVO>> getCommitmentTasks(bool isDone);

  Future<void> updateTaskStatus(bool isDone, CommitmentTaskVO taskVO);

  Future<void> addCommitmentTask(CommitmentTaskVO taskVO);

  Future<void> editCommitmentTask(CommitmentTaskVO taskVO);

  Future<void> deleteCommitmentTask(CommitmentTaskVO taskVO);

  /// Watch all tasks belonging to a specific commitment detail.
  Stream<List<ExpnsCommitmentTask>> watchAllByCommitmentDetail(
    String commitmentDetailId,
  );

  /// Delete all tasks linked to a specific [commitmentDetailId].
  /// Called when a CommitmentDetail is deleted to avoid orphaned tasks.
  Future<void> deleteByCommitmentDetailId(String commitmentDetailId);

  /// Delete all tasks linked to a specific [commitmentId].
  Future<void> deleteByCommitmentId(String commitmentId);
}
