import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_detail_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ICommitmentDetailRepository extends ICrudRepository<
    CommitmentDetailTable,
    $CommitmentDetailTableTable,
    CommitmentDetailTableCompanion,
    ExpnsCommitmentDetail> {
  ICommitmentDetailRepository(AppDatabase db)
      : super(db, db.commitmentDetailTable);

  Stream<List<ExpnsCommitmentDetail>> watchAllByCommitment(
      ExpnsCommitment commitment);

  Future<void> deleteByCommitmentId(String commitmentId);
}
