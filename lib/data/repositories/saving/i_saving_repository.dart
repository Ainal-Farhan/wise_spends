import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/composite/saving_with_money_storage.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

abstract class ISavingRepository
    extends
        ICrudRepository<
          SavingTable,
          $SavingTableTable,
          SavingTableCompanion,
          SvngSaving
        > {
  ISavingRepository(AppDatabase db) : super(db, db.savingTable);

  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId);

  Stream<List<SvngSaving>> watchBasedOnMoneyStorageId(
    final String moneyStorageId,
  );

  Stream<List<SavingWithMoneyStorage>>
  watchSavingListWithMoneyStorageBasedOnUserId(String userId);

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

  Future<List<ListSavingVO>> getDailyUsageSavings();
  Future<List<ListSavingVO>> getCreditSavings();
  Future<List<ListSavingVO>> getAllSavings();
  Future<void> makeTransaction({
    required String sourceSavingId,
    String? destinationSavingId,
    required double amount,
    required String transactionType,
    String? reference,
  });
}
