import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/expense/i_commitment_repository.dart';

class CommitmentRepository extends ICommitmentRepository {
  CommitmentRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'CommitmentTable';

  @override
  Stream<List<ExpnsCommitment>> watchAllByUser(CmmnUser user) {
    return (db.select(db.commitmentTable)
          ..where((table) => table.userId.equals(user.id)))
        .watch();
  }
}
