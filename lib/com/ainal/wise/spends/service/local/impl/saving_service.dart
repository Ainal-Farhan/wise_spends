import 'package:rxdart/rxdart.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_saving_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_transaction_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/saving_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/transaction_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_saving_service.dart';

class SavingService extends ISavingService {
  final ITransactionRepository _transactionRepository = TransactionRepository();
  final ISavingRepository _savingRepository = SavingRepository();

  SavingService() : super(SavingRepository());

  @override
  Stream<List<SavingWithTransactions>> watchAllSavingWithTransactions(
      final String userId) {
    final savingStream = _savingRepository.watchBasedOnUserId(userId);
    final transactionStream = _transactionRepository.watch();

    return Rx.combineLatest2(savingStream, transactionStream,
        (List<CmnSaving> savingList, List<CmnTransaction> transactionList) {
      return savingList.map((saving) {
        final transactions = transactionList
            .where((transaction) => transaction.savingId == saving.id)
            .toList();
        return SavingWithTransactions(
            transactions: transactions, saving: saving);
      }).toList();
    });
  }
}
