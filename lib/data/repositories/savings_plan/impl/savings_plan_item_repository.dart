import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_item_repository.dart';

/// Savings Plan Item Repository Implementation
class SavingsPlanItemRepository extends ISavingsPlanItemRepository {
  SavingsPlanItemRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'SavingsPlanItemTable';

  @override
  Stream<List<SvngPlnItem>> watchByPlanId(String planId) {
    return (db.select(db.savingsPlanItemTable)
          ..where((tbl) => tbl.planId.equals(planId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  @override
  Future<List<SvngPlnItem>> getByPlanId(String planId) async {
    return (db.select(db.savingsPlanItemTable)
          ..where((tbl) => tbl.planId.equals(planId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();
  }

  @override
  Future<void> deleteByPlanId(String planId) async {
    await (db.delete(
      db.savingsPlanItemTable,
    )..where((tbl) => tbl.planId.equals(planId))).go();
    
    // Update plan's current amount after deletion
    await _updatePlanCurrentAmount(planId);
  }

  @override
  Future<SvngPlnItem> insertOne(SavingsPlanItemTableCompanion companion) async {
    final item = await db.into(table).insertReturning(companion);
    // Update plan's current amount after insertion
    await _updatePlanCurrentAmount(companion.planId.value);
    return item;
  }

  @override
  Future<void> updatePart({
    required SavingsPlanItemTableCompanion tableCompanion,
    required String id,
  }) async {
    // Get the item first to find the planId
    final item = await getById(id);
    if (item != null) {
      await (db.update(table)..where((tbl) => tbl.id.equals(id))).write(tableCompanion);
      // Update plan's current amount after update
      await _updatePlanCurrentAmount(item.planId);
    }
  }

  @override
  Future<void> deleteById({required String id}) async {
    // Get the item first to find the planId
    final item = await getById(id);
    if (item != null) {
      await (db.delete(table)..where((tbl) => tbl.id.equals(id))).go();
      // Update plan's current amount after deletion
      await _updatePlanCurrentAmount(item.planId);
    }
  }

  @override
  Future<SvngPlnItem?> getById(String itemId) async {
    return (db.select(
      db.savingsPlanItemTable,
    )..where((tbl) => tbl.id.equals(itemId))).getSingleOrNull();
  }

  @override
  Future<void> updateSortOrder(String itemId, double newSortOrder) async {
    await (db.update(db.savingsPlanItemTable)
          ..where((tbl) => tbl.id.equals(itemId)))
        .write(SavingsPlanItemTableCompanion(sortOrder: Value(newSortOrder)));
  }

  @override
  Future<double> getNextSortOrder(String planId) async {
    final items = await getByPlanId(planId);
    if (items.isEmpty) return 1000.0;
    final maxSortOrder = items
        .map((i) => i.sortOrder)
        .reduce((a, b) => a > b ? a : b);
    return maxSortOrder + 1000.0;
  }

  /// Helper method to update the parent plan's currentAmount
  /// This ensures item payments are included in the plan's total
  Future<void> _updatePlanCurrentAmount(String planId) async {
    try {
      // Get total payments from budget plan items
      final items = await getByPlanId(planId);
      final totalItemPayments = items.fold<double>(
        0.0,
        (sum, i) => sum + i.amountPaid,
      );

      // Get total deposits from manual deposits
      final deposits = await (db.select(db.savingsPlanDepositTable)
            ..where((tbl) => tbl.planId.equals(planId)))
          .get();
      final totalDeposits = deposits.fold<double>(
        0.0,
        (sum, d) => sum + d.amount,
      );

      // Get total spending from manual spending
      final transactions = await (db.select(db.savingsPlanSpendingTable)
            ..where((tbl) => tbl.planId.equals(planId)))
          .get();
      final totalSpending = transactions.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      // Update plan: currentAmount = manual deposits + item payments - spending
      final currentAmount = totalDeposits + totalItemPayments - totalSpending;

      await (db.update(db.savingsPlanTable)
            ..where((tbl) => tbl.id.equals(planId)))
        .write(SavingsPlanTableCompanion(
          currentAmount: Value(currentAmount),
          dateUpdated: Value(DateTime.now()),
          lastModifiedBy: Value('system'),
        ));
    } catch (e) {
      // Silently fail - don't block item operations if plan update fails
      // The plan amount will be recalculated on next load
    }
  }

  @override
  SvngPlnItem fromJson(Map<String, dynamic> json) => SvngPlnItem.fromJson(json);
}
