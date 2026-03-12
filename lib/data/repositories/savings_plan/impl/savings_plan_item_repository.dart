import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/i_budget_plan_repository.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/impl/budget_plan_repository.dart';
import 'package:wise_spends/data/repositories/savings_plan/i_savings_plan_item_repository.dart';

/// Savings Plan Item Repository Implementation
/// Uses IBudgetPlanRepository for centralized plan amount calculation
class SavingsPlanItemRepository extends ISavingsPlanItemRepository {
  final IBudgetPlanRepository _budgetPlanRepository;

  SavingsPlanItemRepository({IBudgetPlanRepository? budgetPlanRepository})
    : _budgetPlanRepository = budgetPlanRepository ?? BudgetPlanRepository(),
      super(AppDatabase());

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

    // Recalculate plan's current amount using centralized method
    await _budgetPlanRepository.recalculatePlanAmount(planId);
  }

  @override
  Future<SvngPlnItem> insertOne(SavingsPlanItemTableCompanion companion) async {
    final item = await db.into(table).insertReturning(companion);
    // Recalculate plan's current amount using centralized method
    await _budgetPlanRepository.recalculatePlanAmount(companion.planId.value);
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
      await (db.update(
        table,
      )..where((tbl) => tbl.id.equals(id))).write(tableCompanion);
      // Recalculate plan's current amount using centralized method
      await _budgetPlanRepository.recalculatePlanAmount(item.planId);
    }
  }

  @override
  Future<void> deleteById({required String id}) async {
    // Get the item first to find the planId
    final item = await getById(id);
    if (item != null) {
      await (db.delete(table)..where((tbl) => tbl.id.equals(id))).go();
      // Recalculate plan's current amount using centralized method
      await _budgetPlanRepository.recalculatePlanAmount(item.planId);
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

  @override
  SvngPlnItem fromJson(Map<String, dynamic> json) => SvngPlnItem.fromJson(json);
}
