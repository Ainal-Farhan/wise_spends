import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/expense/i_commitment_detail_repository.dart';

class CommitmentDetailRepository extends ICommitmentDetailRepository {
  CommitmentDetailRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'CommitmentDetailTable';

  @override
  Stream<List<ExpnsCommitmentDetail>> watchAllByCommitment(
      ExpnsCommitment commitment) {
    return (db.select(db.commitmentDetailTable)
          ..where((table) => table.commitmentId.equals(commitment.id)))
        .watch();
  }

  @override
  Future<void> deleteByCommitmentId(String commitmentId) async {
    db.delete(table).where((tbl) => tbl.commitmentId.equals(commitmentId));
  }
}
