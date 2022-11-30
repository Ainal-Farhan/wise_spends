import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_transaction_repository.dart';

class TransactionRepository extends ITransactionRepository {
  TransactionRepository() : super(AppDatabase());
}
