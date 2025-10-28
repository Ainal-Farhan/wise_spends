import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_task_vo.dart';

abstract class ICommitmentTaskRepository {
  Future<List<CommitmentTaskVO>> getCommitmentTasks();
  Future<void> updateTaskStatus(bool isDone, CommitmentTaskVO taskVO);
}

class CommitmentTaskRepository implements ICommitmentTaskRepository {
  final commitmentManager = SingletonUtil.getSingleton<IManagerLocator>()!.getCommitmentManager();

  @override
  Future<List<CommitmentTaskVO>> getCommitmentTasks() async {
    try {
      return await commitmentManager.retrieveListOfCommitmentTask(false);
    } catch (e) {
      throw Exception('Failed to load commitment tasks: $e');
    }
  }

  @override
  Future<void> updateTaskStatus(bool isDone, CommitmentTaskVO taskVO) async {
    try {
      await commitmentManager.updateStatusCommitmentTask(isDone, taskVO);
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }
}