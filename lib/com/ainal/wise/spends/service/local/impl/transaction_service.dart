import 'package:rxdart/rxdart.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_saving_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_transaction_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/saving_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/transaction_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/impl/local_service.dart';

class TransactionService extends LocalService<CmnTransaction> {
  final ITransactionRepository _transactionRepository = TransactionRepository();
  final ISavingRepository _savingRepository = SavingRepository();

  TransactionService() : super(TransactionRepository());

  Stream<List<SavingWithTransactions>> watchAllSavingWithTransactions() {
    final savingStream = _savingRepository.watch();
    final transactionStream = _transactionRepository.watch();

    return Rx.combineLatest2(savingStream, transactionStream,
        (List<CmnSaving> a, List<CmnTransaction> b) {
      return a.map((saving) {
        final transactions =
            b.where((transaction) => transaction.saving == saving.id).toList();

        return SavingWithTransactions(
            transactions: transactions, saving: saving);
      }).toList();
    });
  }
}
