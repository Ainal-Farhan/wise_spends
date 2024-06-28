import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/repository/transaction/i_transaction_repository.dart';
import 'package:wise_spends/service/local/transaction/i_transaction_service.dart';
import 'package:wise_spends/util/singleton_util.dart';

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
