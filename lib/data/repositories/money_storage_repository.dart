import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';
import 'package:wise_spends/vo/impl/money_storage/money_storage_vo.dart';

abstract class IMoneyStorageRepository {
  Future<List<MoneyStorageVO>> getMoneyStorageList();
  Future<MoneyStorageVO?> getMoneyStorageById(String id);
  Future<void> addMoneyStorage(String shortName, String longName, double amount);
  Future<void> updateMoneyStorage(String id, String shortName, String longName, double amount);
  Future<void> deleteMoneyStorage(String id);
}

class MoneyStorageRepository implements IMoneyStorageRepository {
  final savingManager = SingletonUtil.getSingleton<IManagerLocator>()!.getSavingManager();

  @override
  Future<List<MoneyStorageVO>> getMoneyStorageList() async {
    try {
      return await savingManager.getCurrentUserMoneyStorageVOList();
    } catch (e) {
      throw Exception('Failed to load money storage: $e');
    }
  }

  @override
  Future<MoneyStorageVO?> getMoneyStorageById(String id) async {
    try {
      final allStorages = await getMoneyStorageList();
      return allStorages.firstWhere((storage) => storage.moneyStorage.id == id, orElse: () => throw Exception('Storage not found'));
    } catch (e) {
      throw Exception('Failed to find money storage: $e');
    }
  }

  @override
  Future<void> addMoneyStorage(String shortName, String longName, double amount) async {
    try {
      await savingManager.addNewMoneyStorage(
        shortName: shortName,
        longName: longName,
        type: 'General', // Default type, could be made configurable
      );
    } catch (e) {
      throw Exception('Failed to add money storage: $e');
    }
  }

  @override
  Future<void> updateMoneyStorage(String id, String shortName, String longName, double amount) async {
    try {
      final editMoneyStorageFormVO = EditMoneyStorageFormVO(
        id: id,
        shortName: shortName,
        longName: longName,
        type: 'General', // Default type for update
      );
        
      await savingManager.updateMoneyStorage(
        editMoneyStorageFormVO: editMoneyStorageFormVO,
      );
    } catch (e) {
      throw Exception('Failed to update money storage: $e');
    }
  }

  @override
  Future<void> deleteMoneyStorage(String id) async {
    try {
      await savingManager.deleteSelectedMoneyStorage(id);
    } catch (e) {
      throw Exception('Failed to delete money storage: $e');
    }
  }
}