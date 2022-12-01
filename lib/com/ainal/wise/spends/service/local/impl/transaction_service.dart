import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/transaction_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_transaction_service.dart';

class TransactionService extends ITransactionService {
  TransactionService() : super(TransactionRepository());
}
