import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/expense/i_commitment_detail_repository.dart';

class CommitmentDetailRepository extends ICommitmentDetailRepository {
  CommitmentDetailRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'CommitmentDetailTable';
}
