import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/impl/saving/edit_saving_form_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

abstract class ISavingsRepository {
  Future<List<ListSavingVO>> getSavingsList();
  Future<ListSavingVO?> getSavingById(String id);
  Future<void> addSaving({
    required String name,
    required double initialAmount,
    required bool isHasGoal,
    required double goalAmount,
    required String moneyStorageId,
    required String savingType,
  });
  Future<void> updateSaving({
    required String id,
    required String name,
    required double initialAmount,
    required bool isHasGoal,
    required double goalAmount,
    required String moneyStorageId,
    required String savingType,
  });
  Future<void> deleteSaving(String id);
  Future<List<SvngMoneyStorage>> getMoneyStorageOptions();
}

class SavingsRepository implements ISavingsRepository {
  final savingManager = SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  @override
  Future<List<ListSavingVO>> getSavingsList() async {
    try {
      return await savingManager.loadListSavingVOList();
    } catch (e) {
      throw Exception('Failed to load savings: $e');
    }
  }

  @override
  Future<ListSavingVO?> getSavingById(String id) async {
    try {
      final allSavings = await getSavingsList();
      return allSavings.firstWhere((saving) => saving.saving.id == id, orElse: () => throw Exception('Saving not found'));
    } catch (e) {
      throw Exception('Failed to find saving: $e');
    }
  }

  @override
  Future<void> addSaving({
    required String name,
    required double initialAmount,
    required bool isHasGoal,
    required double goalAmount,
    required String moneyStorageId,
    required String savingType,
  }) async {
    try {
      final savingTypeEnum = SavingTableType.findByValue(savingType);
      if (savingTypeEnum == null) {
        throw Exception('Invalid saving type: $savingType');
      }
      
      await savingManager.addNewSaving(
        name: name,
        initialAmount: initialAmount,
        isHasGoal: isHasGoal,
        goalAmount: goalAmount,
        moneyStorageId: moneyStorageId,
        savingTableType: savingTypeEnum,
      );
    } catch (e) {
      throw Exception('Failed to add saving: $e');
    }
  }

  @override
  Future<void> updateSaving({
    required String id,
    required String name,
    required double initialAmount,
    required bool isHasGoal,
    required double goalAmount,
    required String moneyStorageId,
    required String savingType,
  }) async {
    try {
      final savingTypeEnum = SavingTableType.findByValue(savingType);
      if (savingTypeEnum == null) {
        throw Exception('Invalid saving type: $savingType');
      }

      final editSavingFormVO = EditSavingFormVO(
        savingId: id,
        savingName: name,
        currentAmount: initialAmount, // Note: this might be wrong - need to verify
        goalAmount: goalAmount,
        isHasGoal: isHasGoal,
        moneyStorageId: moneyStorageId,
        savingTableType: savingTypeEnum,
      );

      await savingManager.updateSaving(editSavingFormVO: editSavingFormVO);
    } catch (e) {
      throw Exception('Failed to update saving: $e');
    }
  }

  @override
  Future<void> deleteSaving(String id) async {
    try {
      await savingManager.deleteSelectedSaving(id);
    } catch (e) {
      throw Exception('Failed to delete saving: $e');
    }
  }
  
  @override
  Future<List<SvngMoneyStorage>> getMoneyStorageOptions() async {
    try {
      return await savingManager.getCurrentUserMoneyStorageList();
    } catch (e) {
      throw Exception('Failed to load money storage options: $e');
    }
  }
}