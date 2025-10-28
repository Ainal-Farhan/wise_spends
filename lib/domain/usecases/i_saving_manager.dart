import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/composite/saving_with_transactions.dart';
import 'package:wise_spends/domain/usecases/i_manager.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/edit_money_storage_form_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/edit_saving_form_vo.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/money_storage_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

abstract class ISavingManager extends IManager {
  Future<List<SavingWithTransactions>> loadSavingWithTransactionsAsync();

  Future<List<ListSavingVO>> loadListSavingVOList();

  Future<SvngSaving> addNewSaving(
      {required String name,
      required double initialAmount,
      required bool isHasGoal,
      required double goalAmount,
      required String moneyStorageId,
      required SavingTableType savingTableType});

  Future<SvngMoneyStorage> addNewMoneyStorage({
    required String shortName,
    required String longName,
    required String type,
  });

  Future<void> updateSavingCurrentAmount({
    required String savingId,
    required String transactionType,
    required double transactionAmount,
  });

  Future<void> updateMoneyStorage({
    required EditMoneyStorageFormVO editMoneyStorageFormVO,
  });

  Future<void> updateSaving({required EditSavingFormVO editSavingFormVO});

  Future<SvngSaving?> getSavingById(String savingId);

  Future<List<SvngMoneyStorage>> getCurrentUserMoneyStorageList();

  Future<List<MoneyStorageVO>> getCurrentUserMoneyStorageVOList();

  Future<bool> deleteSelectedSaving(String id);

  Future<bool> deleteSelectedMoneyStorage(String id);

  Future<List<DropDownValueModel>>
      getCurrentUserMoneyStorageDropDownValueModelList();
}
