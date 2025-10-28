import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/money_storage_repository.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/edit_money_storage_form_vo.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/money_storage_vo.dart';

class MoneyStorageRepository extends IMoneyStorageRepository {
  final savingManager = SingletonUtil.getSingleton<IManagerLocator>()!
      .getSavingManager();

  MoneyStorageRepository() : super(AppDatabase());

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
      return allStorages.firstWhere(
        (storage) => storage.moneyStorage.id == id,
        orElse: () => throw Exception('Storage not found'),
      );
    } catch (e) {
      throw Exception('Failed to find money storage: $e');
    }
  }

  @override
  Future<void> addMoneyStorage(
    String shortName,
    String longName,
    double amount,
  ) async {
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
  Future<void> updateMoneyStorage(
    String id,
    String shortName,
    String longName,
    double amount,
  ) async {
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

  // Watch all MoneyStorage entries for a specific userId
  @override
  Stream<List<SvngMoneyStorage>> watchBasedOnUserId(String userId) {
    final query = (db.select(
      table,
    )..where((tbl) => tbl.userId.equals(userId))).watch();

    return query;
  }

  @override
  String getTypeName() => 'MoneyStorageTable';
}
