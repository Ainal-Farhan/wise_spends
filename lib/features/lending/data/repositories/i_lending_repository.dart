import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/lending/lending_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ILendingRepository
    extends
        ICrudRepository<
          LendingTable,
          $LendingTableTable,
          LendingTableCompanion,
          LndngLending
        > {
  ILendingRepository(AppDatabase db) : super(db, db.lendingTable);

  Future<List<LndngLending>> getAllLendings();
  Future<LndngLending?> getLendingById(String id);
  Future<void> addLending({
    required String borrowerName,
    required double principalAmount,
    required DateTime lendingDate,
    DateTime? dueDate,
    String sourceSavingId,
    String? note,
    bool noAutoDeduct,
  });

  /// Updates lending metadata only — does NOT touch saving balances.
  Future<void> updateLending({
    required String id,
    required String borrowerName,
    required double principalAmount,
    required DateTime lendingDate,
    DateTime? dueDate,
    String? note,
    bool noAutoDeduct,
  });
  Future<void> deleteLending(String id);
  Future<void> settleLending(String id);
  Future<double> getOutstandingAmount(String lendingId);
}
