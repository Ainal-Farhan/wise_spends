import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/expense/i_commitment_detail_repository.dart';

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
  Future<void> deleteAllByCommitmentId(String commitmentId) async {
    (db.delete(db.commitmentDetailTable)
      ..where((table) => table.commitmentId.equals(commitmentId)));
  }
}
