import 'package:drift/drift.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/commitment/data/repositories/i_commitment_task_repository.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';

class CommitmentTaskRepository extends ICommitmentTaskRepository {
  CommitmentTaskRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'CommitmentTaskTable';

  @override
  Stream<List<ExpnsCommitmentTask>> watchAll(bool isDone) {
    return (db.select(table)
          ..where((t) => t.isDone.equals(isDone))
          ..orderBy([(t) => OrderingTerm.desc(t.dateUpdated)]))
        .watch();
  }

  @override
  Future<List<CommitmentTaskVO>> getCommitmentTasks(
    bool isDone, {
    int? limit,
    int? offset,
  }) async {
    try {
      return await SingletonUtil.getSingleton<IManagerLocator>()!
          .getCommitmentManager()
          .retrieveListOfCommitmentTask(isDone, limit: limit, offset: offset);
    } catch (e) {
      throw Exception('Failed to load commitment tasks: $e');
    }
  }

  @override
  Future<void> updateTaskStatus(bool isDone, CommitmentTaskVO taskVO) async {
    try {
      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getCommitmentManager()
          .updateStatusCommitmentTask(isDone, taskVO);
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  @override
  Future<void> addCommitmentTask(CommitmentTaskVO taskVO) async {
    try {
      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getCommitmentManager()
          .addCommitmentTask(taskVO);
    } catch (e) {
      throw Exception('Failed to add commitment task: $e');
    }
  }

  @override
  Future<void> editCommitmentTask(CommitmentTaskVO taskVO) async {
    try {
      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getCommitmentManager()
          .editCommitmentTask(taskVO);
    } catch (e) {
      throw Exception('Failed to edit commitment task: $e');
    }
  }

  @override
  Future<void> deleteCommitmentTask(CommitmentTaskVO taskVO) async {
    try {
      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getCommitmentManager()
          .deleteCommitmentTask(taskVO);
    } catch (e) {
      throw Exception('Failed to delete commitment task: $e');
    }
  }

  @override
  Stream<List<ExpnsCommitmentTask>> watchAllByCommitmentDetail(
    String commitmentDetailId,
  ) {
    return (db.select(table)
          ..where((t) => t.commitmentDetailId.equals(commitmentDetailId))
          ..orderBy([(t) => OrderingTerm.desc(t.dateUpdated)]))
        .watch();
  }

  @override
  Future<void> deleteByCommitmentDetailId(String commitmentDetailId) async {
    await (db.delete(
      table,
    )..where((t) => t.commitmentDetailId.equals(commitmentDetailId))).go();
  }

  @override
  Future<void> deleteByCommitmentId(String commitmentId) async {
    await (db.delete(
      table,
    )..where((t) => t.commitmentId.equals(commitmentId))).go();
  }

  @override
  ExpnsCommitmentTask fromJson(Map<String, dynamic> json) =>
      ExpnsCommitmentTask.fromJson(json);
}
