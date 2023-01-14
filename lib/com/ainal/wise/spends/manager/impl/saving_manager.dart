import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/saving/saving_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/saving/i_saving_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/saving/impl/saving_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/transaction/i_transaction_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/transaction/impl/transaction_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/edit_saving_form_vo.dart';

class SavingManager implements ISavingManager {
  final ISavingService _savingService = SavingService();
  final ITransactionService _transactionService = TransactionService();
  final IStartupManager _startupManager = IStartupManager();

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
    required bool isHasGoal,
    required double goalAmount,
  }) async {
    SavingTableCompanion savingTableCompanion = SavingTableCompanion.insert(
      dateUpdated: DateTime.now(),
      name: Value(name),
      userId: Value(_startupManager.currentUser.id),
      currentAmount: Value(initialAmount),
      isHasGoal: Value(isHasGoal),
      goal: Value(goalAmount),
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
      id: Value(savingId),
      dateUpdated: DateTime.now(),
      currentAmount: Value(currentAmount),
    );

    await _savingService.updatePart(updatedSaving);
  }

  @override
  Future<void> updateSaving(
      {required EditSavingFormVO editSavingFormVO}) async {
    SavingTableCompanion updatedSaving = SavingTableCompanion(
      id: Value(editSavingFormVO.savingId),
      name: Value(editSavingFormVO.savingName),
      currentAmount: Value(editSavingFormVO.currentAmount),
      isHasGoal: Value(editSavingFormVO.isHasGoal),
      goal: Value(
        editSavingFormVO.isHasGoal ? editSavingFormVO.goalAmount : .0,
      ),
      dateUpdated: Value(DateTime.now()),
    );

    await _savingService.updatePart(updatedSaving);
  }
}
