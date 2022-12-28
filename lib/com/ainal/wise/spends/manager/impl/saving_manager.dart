import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/saving/saving_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/saving/impl/saving_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/transaction/i_transaction_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/transaction/impl/transaction_service.dart';

class SavingManager extends ISavingManager {
  final ISavingService _savingService = SavingService();
  final ITransactionService _transactionService = TransactionService();
  final IStartupManager _startupManager = StartupManager();

  @override
  Future<List<SavingWithTransactions>> loadSavingWithTransactionsAsync() async {
    Stream<List<SavingWithTransactions>> streamSavingWithTransactionsList =
        _savingService
            .watchAllSavingWithTransactions(_startupManager.currentUser.id);
    return await streamSavingWithTransactionsList.first;
  }

  @override
  Future<void> addNewSaving({
    required String name,
    required double initialAmount,
  }) async {
    SavingTableCompanion savingTableCompanion = SavingTableCompanion.insert(
      dateUpdated: DateTime.now(),
      name: name,
      userId: _startupManager.currentUser.id,
      currentAmount: Value(initialAmount),
    );

    return await _savingService.add(savingTableCompanion);
  }

  @override
  Future<bool> deleteSelectedSaving(String id) async {
    try {
      // get saving
      SvngSaving saving = await _savingService.watchSavingById(id).first;

      // delete all transactions based on savingId
      await _transactionService.deleteAllBasedOnSavingId(saving.id);

      // delete saving
      await _savingService.delete(saving);

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<SvngSaving> getSavingById(String savingId) async {
    return await _savingService.watchSavingById(savingId).first;
  }

  @override
  Future<void> updateSavingCurrentAmount({
    required String savingId,
    required String transactionType,
    required double transactionAmount,
  }) async {
    SvngSaving currentSaving =
        await _savingService.watchSavingById(savingId).first;

    double currentAmount = currentSaving.currentAmount;

    switch (transactionType) {
      case SavingConstant.savingTransactionIn:
        currentAmount += transactionAmount;
        break;
      case SavingConstant.savingTransactionOut:
        currentAmount -= transactionAmount;
    }
    SavingTableCompanion updatedSaving = SavingTableCompanion.insert(
      name: currentSaving.name,
      userId: currentSaving.userId,
      id: Value(savingId),
      dateUpdated: DateTime.now(),
      currentAmount: Value(currentAmount),
    );

    await _savingService.updatePart(updatedSaving);
  }
}
