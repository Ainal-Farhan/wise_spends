import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/composite/saving_with_transactions.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/saving_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/saving/edit_saving_form_vo.dart';

abstract class ISavingManager extends IManager {
  factory ISavingManager() {
    return SavingManager();
  }

  Future<List<SavingWithTransactions>> loadSavingWithTransactionsAsync();

  Future<void> addNewSaving({
    required String name,
    required double initialAmount,
    required bool isHasGoal,
    required double goalAmount,
    required String moneyStorageId,
  });

  Future<void> updateSavingCurrentAmount({
    required String savingId,
    required String transactionType,
    required double transactionAmount,
  });

  Future<void> updateSaving({required EditSavingFormVO editSavingFormVO});

  Future<SvngSaving> getSavingById(String savingId);

  Future<bool> deleteSelectedSaving(String id);

  Future<List<DropDownValueModel>>
      getCurrentUserMoneyStorageDropDownValueModelList();
}
