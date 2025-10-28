import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_task_repository.dart';

class CommitmentTaskRepository extends ICommitmentTaskRepository {
  CommitmentTaskRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'CommitmentTaskTable';

  @override
  Stream<List<ExpnsCommitmentTask>> watchAll(bool isDone) {
    return (db.select(db.commitmentTaskTable)
          ..where((table) => table.isDone.equals(isDone)))
        .watch();
  }
}
