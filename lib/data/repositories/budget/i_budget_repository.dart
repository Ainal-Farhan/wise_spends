import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/budget/index.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';

/// Budget repository interface - defines contract for data layer
abstract class IBudgetRepository
    extends
        ICrudRepository<
          SpendingBudgetTable,
          $SpendingBudgetTableTable,
          SpendingBudgetTableCompanion,
          BdgtSpendingBudget
        > {
  IBudgetRepository(AppDatabase db) : super(db, db.spendingBudgetTable);

  /// Get all budgets
  Future<List<BudgetEntity>> getAllBudgets();

  /// Get active budgets
  Future<List<BudgetEntity>> getActiveBudgets();

  /// Get budgets by category
  Future<List<BudgetEntity>> getBudgetsByCategory(String categoryId);

  /// Get a single budget by ID
  Future<BudgetEntity?> getBudgetById(String id);

  /// Get budget for current period by category
  Future<BudgetEntity?> getCurrentBudgetByCategory(String categoryId);

  /// Create a new budget
  Future<BudgetEntity> createBudget(BudgetEntity budget);

  /// Update an existing budget
  Future<BudgetEntity> updateBudget(BudgetEntity budget);

  /// Update spent amount for a budget
  Future<BudgetEntity> updateBudgetSpentAmount(
    String budgetId,
    double spentAmount,
  );

  /// Delete a budget
  Future<void> deleteBudget(String id);

  /// Get total budget limit for current period
  Future<double> getTotalBudgetLimit();

  /// Get total spent from all budgets
  Future<double> getTotalSpentFromBudgets();

  /// Get number of budgets on track (not exceeded)
  Future<int> getBudgetsOnTrackCount();

  /// Get number of total active budgets
  Future<int> getTotalActiveBudgetsCount();
}
