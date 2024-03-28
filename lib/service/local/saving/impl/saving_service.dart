import 'package:rxdart/rxdart.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/composite/saving_with_money_storage.dart';
import 'package:wise_spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/repository/saving/i_saving_repository.dart';
import 'package:wise_spends/repository/transaction/i_transaction_repository.dart';
import 'package:wise_spends/repository/saving/impl/saving_repository.dart';
import 'package:wise_spends/repository/transaction/impl/transaction_repository.dart';
import 'package:wise_spends/service/local/saving/i_saving_service.dart';

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
        (List<SvngSaving> savingList,
            List<TrnsctnTransaction> transactionList) {
      return savingList.map((saving) {
        final transactions = transactionList
            .where((transaction) => transaction.savingId == saving.id)
            .toList();
        return SavingWithTransactions(
            transactions: transactions, saving: saving);
      }).toList();
    });
  }

  @override
  Stream<SvngSaving> watchSavingById(String savingId) {
    return _savingRepository.watchBasedOnSavingId(savingId);
  }

  @override
  Future<void> updatePart(SavingTableCompanion savingTableCompanion) async {
    await _savingRepository.updatePart(
        savingTableCompanion, savingTableCompanion.id.value);
  }

  @override
  Stream<List<SvngSaving>> watchAllSavingBasedOnMoneyStorageId(
      String moneyStorageId) {
    return _savingRepository.watchBasedOnMoneyStorageId(moneyStorageId);
  }

  @override
  Stream<List<SavingWithMoneyStorage>>
      watchAllSavingWithMoneyStorageBasedOnUserId(String userId) {
    return _savingRepository
        .watchSavingListWithMoneyStorageBasedOnUserId(userId);
  }
}
