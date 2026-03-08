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

  @override
  SvngPlnItem fromJson(Map<String, dynamic> json) => SvngPlnItem.fromJson(json);
}
