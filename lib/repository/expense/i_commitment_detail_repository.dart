import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/expense/commitment_detail_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class ICommitmentDetailRepository extends ICrudRepository<
    CommitmentDetailTable,
    $CommitmentDetailTableTable,
    CommitmentDetailTableCompanion,
    ExpnsCommitmentDetail> {
  ICommitmentDetailRepository(AppDatabase db)
      : super(db, db.commitmentDetailTable);

  Stream<List<ExpnsCommitmentDetail>> watchAllByCommitment(
      ExpnsCommitment commitment);
}
