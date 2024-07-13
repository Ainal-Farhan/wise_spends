import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/expense/commitent_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class ICommitmentRepository extends ICrudRepository<CommitmentTable,
    $CommitmentTableTable, CommitmentTableCompanion, ExpnsCommitment> {
  ICommitmentRepository(AppDatabase db) : super(db, db.commitmentTable);
}
