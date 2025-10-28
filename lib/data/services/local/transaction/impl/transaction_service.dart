import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/data/services/local/transaction/i_transaction_service.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';

class TransactionService extends ITransactionService {
  TransactionService()
      : super(SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getTransactionRepository());

  final ITransactionRepository _transactionRepository =
      SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getTransactionRepository();

  @override
  Future<void> deleteAllBasedOnSavingId(String savingId) async {
    await _transactionRepository.deleteBasedOnSavingId(savingId);
  }
}
