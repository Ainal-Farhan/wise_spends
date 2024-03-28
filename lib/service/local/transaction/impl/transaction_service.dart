import 'package:wise_spends/repository/transaction/impl/transaction_repository.dart';
import 'package:wise_spends/service/local/transaction/i_transaction_service.dart';

class TransactionService extends ITransactionService {
  TransactionService() : super(TransactionRepository());

  final TransactionRepository _transactionRepository = TransactionRepository();

  @override
  Future<void> deleteAllBasedOnSavingId(String savingId) async {
    await _transactionRepository.deleteBasedOnSavingId(savingId);
  }
}
