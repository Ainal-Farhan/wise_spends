import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/transaction_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/impl/local_service.dart';

class TransactionService extends LocalService<CmnTransaction> {
  TransactionService() : super(TransactionRepository());
}
