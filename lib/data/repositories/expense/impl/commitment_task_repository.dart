import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_task_repository.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_task_vo.dart';

class CommitmentTaskRepository extends ICommitmentTaskRepository {
  CommitmentTaskRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'CommitmentTaskTable';

  @override
  Stream<List<ExpnsCommitmentTask>> watchAll(bool isDone) {
    return (db.select(
      db.commitmentTaskTable,
    )..where((table) => table.isDone.equals(isDone))).watch();
  }

  @override
  Future<List<CommitmentTaskVO>> getCommitmentTasks() async {
    try {
      return await SingletonUtil.getSingleton<IManagerLocator>()!
          .getCommitmentManager()
          .retrieveListOfCommitmentTask(false);
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
}
