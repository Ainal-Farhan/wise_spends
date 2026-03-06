import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';
import 'package:wise_spends/data/repositories/budget/i_budget_repository.dart';

/// Budget Repository Implementation
/// Handles all database operations for budgets
class BudgetRepository extends IBudgetRepository {
  final AppDatabase _db = AppDatabase();

  @override
  void dispose() {
    // No resources to dispose
  }

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    final query = _db.select(_db.budgets);
    final rows = await query.get();

    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<List<BudgetEntity>> getActiveBudgets() async {
    final query = _db.select(_db.budgets)
      ..where((tbl) => tbl.isActive.equals(true));
    final rows = await query.get();

    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<List<BudgetEntity>> getBudgetsByCategory(String categoryId) async {
    final query = _db.select(_db.budgets)
      ..where((tbl) => tbl.categoryId.equals(categoryId));
    final rows = await query.get();

    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<BudgetEntity?> getBudgetById(String id) async {
    final query = _db.select(_db.budgets)..where((tbl) => tbl.id.equals(id));
    final rows = await query.get();

    if (rows.isEmpty) return null;
    return _mapToEntity(rows.first);
  }

  @override
  Future<BudgetEntity?> getCurrentBudgetByCategory(String categoryId) async {
    final now = DateTime.now();
    final query = _db.select(_db.budgets)
      ..where(
        (tbl) =>
            tbl.categoryId.equals(categoryId) &
            tbl.isActive.equals(true) &
            tbl.startDate.isSmallerOrEqualValue(now) &
            (tbl.endDate.isNull() | tbl.endDate.isBiggerOrEqualValue(now)),
      );

    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _mapToEntity(rows.first);
  }

  @override
  Future<BudgetEntity> createBudget(BudgetEntity budget) async {
    final companion = BudgetsCompanion.insert(
      id: budget.id,
      name: budget.name,
      categoryId: budget.categoryId,
      limitAmount: budget.limitAmount,
      spentAmount: Value(budget.spentAmount),
      period: budget.period.name,
      startDate: budget.startDate,
      endDate: Value(budget.endDate),
      isActive: Value(budget.isActive),
      createdAt: Value(budget.createdAt),
      updatedAt: Value(budget.updatedAt),
    );

    await _db.into(_db.budgets).insert(companion);
    return budget;
  }

  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    final updating = BudgetsCompanion(
      name: Value(budget.name),
      categoryId: Value(budget.categoryId),
      limitAmount: Value(budget.limitAmount),
      spentAmount: Value(budget.spentAmount),
      period: Value(budget.period.name),
      startDate: Value(budget.startDate),
      endDate: Value(budget.endDate),
      isActive: Value(budget.isActive),
      updatedAt: Value(budget.updatedAt),
    );

    final query = _db.update(_db.budgets)
      ..where((tbl) => tbl.id.equals(budget.id));
    await query.write(updating);

    return budget;
  }

  @override
  Future<BudgetEntity> updateBudgetSpentAmount(
    String budgetId,
    double spentAmount,
  ) async {
    final updating = BudgetsCompanion(
      spentAmount: Value(spentAmount),
      updatedAt: Value(DateTime.now()),
    );

    final query = _db.update(_db.budgets)
      ..where((tbl) => tbl.id.equals(budgetId));
    await query.write(updating);

    return getBudgetById(budgetId).then((budget) => budget!);
  }

  @override
  Future<void> deleteBudget(String id) async {
    final query = _db.delete(_db.budgets)..where((tbl) => tbl.id.equals(id));
    await query.go();
  }

  @override
  Future<double> getTotalBudgetLimit() async {
    final budgets = await getActiveBudgets();
    return budgets.fold<double>(0.0, (sum, budget) => sum + budget.limitAmount);
  }

  @override
  Future<double> getTotalSpentFromBudgets() async {
    final budgets = await getActiveBudgets();
    return budgets.fold<double>(0.0, (sum, budget) => sum + budget.spentAmount);
  }

  @override
  Future<int> getBudgetsOnTrackCount() async {
    final budgets = await getActiveBudgets();
    return budgets.where((b) => !b.isExceeded).length;
  }

  @override
  Future<int> getTotalActiveBudgetsCount() async {
    final budgets = await getActiveBudgets();
    return budgets.length;
  }

  /// Map database row to entity
  BudgetEntity _mapToEntity(Budget row) {
    return BudgetEntity(
      id: row.id,
      name: row.name,
      categoryId: row.categoryId,
      limitAmount: row.limitAmount,
      spentAmount: row.spentAmount,
      period: BudgetPeriod.values.firstWhere(
        (p) => p.name == row.period,
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: row.startDate,
      endDate: row.endDate,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
