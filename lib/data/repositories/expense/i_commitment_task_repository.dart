import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/expense/index.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ICommitmentTaskRepository extends ICrudRepository<
    CommitmentTaskTable,
    $CommitmentTaskTableTable,
    CommitmentTaskTableCompanion,
    ExpnsCommitmentTask> {
  ICommitmentTaskRepository(AppDatabase db) : super(db, db.commitmentTaskTable);

  Stream<List<ExpnsCommitmentTask>> watchAll(bool isDone);
}
