import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/expense/index.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class ICommitmentTaskRepository extends ICrudRepository<
    CommitmentTaskTable,
    $CommitmentTaskTableTable,
    CommitmentTaskTableCompanion,
    ExpnsCommitmentTask> {
  ICommitmentTaskRepository(AppDatabase db) : super(db, db.commitmentTaskTable);

  Stream<List<ExpnsCommitmentTask>> watchAll(bool isDone);
}
