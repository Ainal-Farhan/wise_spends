import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ICommitmentRepository extends ICrudRepository<CommitmentTable,
    $CommitmentTableTable, CommitmentTableCompanion, ExpnsCommitment> {
  ICommitmentRepository(AppDatabase db) : super(db, db.commitmentTable);

  Stream<List<ExpnsCommitment>> watchAllByUser(CmmnUser user);
}
