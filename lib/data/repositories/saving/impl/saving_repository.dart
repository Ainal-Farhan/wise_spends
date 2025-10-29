import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/composite/saving_with_money_storage.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/domain/entities/impl/saving/edit_saving_form_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

class SavingRepository extends ISavingRepository {
  SavingRepository() : super(AppDatabase());

  @override
  Future<List<ListSavingVO>> getSavingsList() async {
    try {
      return await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .loadListSavingVOList();
    } catch (e) {
      throw Exception('Failed to load savings: $e');
    }
  }

  @override
  Future<ListSavingVO?> getSavingById(String id) async {
    try {
      final allSavings = await getSavingsList();
      return allSavings.firstWhere(
        (saving) => saving.saving.id == id,
        orElse: () => throw Exception('Saving not found'),
      );
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

      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .addNewSaving(
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
        currentAmount:
            initialAmount, // Note: this might be wrong - need to verify
        goalAmount: goalAmount,
        isHasGoal: isHasGoal,
        moneyStorageId: moneyStorageId,
        savingTableType: savingTypeEnum,
      );

      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .updateSaving(editSavingFormVO: editSavingFormVO);
    } catch (e) {
      throw Exception('Failed to update saving: $e');
    }
  }

  @override
  Future<void> deleteSaving(String id) async {
    try {
      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .deleteSelectedSaving(id);
    } catch (e) {
      throw Exception('Failed to delete saving: $e');
    }
  }

  @override
  Future<List<SvngMoneyStorage>> getMoneyStorageOptions() async {
    try {
      return await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .getCurrentUserMoneyStorageList();
    } catch (e) {
      throw Exception('Failed to load money storage options: $e');
    }
  }

  @override
  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId) {
    return (db.select(
      db.savingTable,
    )..where((tbl) => tbl.userId.equals(userId))).watch();
  }

  @override
  Stream<List<SvngSaving>> watchBasedOnMoneyStorageId(String moneyStorageId) {
    return (db.select(
      db.savingTable,
    )..where((tbl) => tbl.moneyStorageId.equals(moneyStorageId))).watch();
  }

  @override
  Stream<List<SavingWithMoneyStorage>>
  watchSavingListWithMoneyStorageBasedOnUserId(String userId) {
    final query = db.select(db.savingTable).join([
      innerJoin(
        db.moneyStorageTable,
        db.moneyStorageTable.id.equalsExp(db.savingTable.moneyStorageId),
      ),
    ])..where(db.savingTable.userId.equals(userId));

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => SavingWithMoneyStorage(
              saving: row.readTable(db.savingTable),
              moneyStorage: row.readTable(db.moneyStorageTable),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<ListSavingVO>> getDailyUsageSavings() async {
    try {
      final allSavings = await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .loadListSavingVOList();
      return allSavings.where((saving) {
        final type = SavingTableType.findByValue(saving.saving.type);
        return type == SavingTableType.dailyUsage;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load daily usage savings: $e');
    }
  }

  @override
  Future<List<ListSavingVO>> getCreditSavings() async {
    try {
      final allSavings = await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .loadListSavingVOList();
      return allSavings.where((saving) {
        final type = SavingTableType.findByValue(saving.saving.type);
        return type == SavingTableType.credit;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load credit savings: $e');
    }
  }

  @override
  Future<List<ListSavingVO>> getAllSavings() async {
    try {
      return await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .loadListSavingVOList();
    } catch (e) {
      throw Exception('Failed to load all savings: $e');
    }
  }

  @override
  Future<void> makeTransaction({
    required String sourceSavingId,
    String? destinationSavingId,
    required double amount,
    required String transactionType,
    String? reference,
  }) async {
    try {
      // Update the source saving's current amount based on transaction type
      String transactionTypeFormatted = '';
      double transactionAmount = amount;

      if (transactionType == 'out' ||
          (transactionType == 'transfer' && destinationSavingId == null)) {
        transactionTypeFormatted = 'withdrawal';
      } else if (transactionType == 'in') {
        transactionTypeFormatted = 'deposit';
      } else if (transactionType == 'transfer' && destinationSavingId != null) {
        // Handle transfer - subtract from source, add to destination
        transactionTypeFormatted = 'transfer_out';

        // Also make an entry for the destination
        await SingletonUtil.getSingleton<IManagerLocator>()!
            .getSavingManager()
            .updateSavingCurrentAmount(
              savingId: destinationSavingId,
              transactionType: 'transfer_in',
              transactionAmount: amount,
            );
      }

      await SingletonUtil.getSingleton<IManagerLocator>()!
          .getSavingManager()
          .updateSavingCurrentAmount(
            savingId: sourceSavingId,
            transactionType: transactionTypeFormatted,
            transactionAmount: transactionAmount,
          );
    } catch (e) {
      throw Exception('Failed to make transaction: $e');
    }
  }

  @override
  String getTypeName() => 'SavingTable';
}
