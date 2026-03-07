import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/savings_plan/index.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_deposit_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_transaction_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_milestone_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/linked_account_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_analytics.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import '../../../domain/entities/budget_plan/budget_plan_params.dart';

/// Budget Plan Repository Interface - defines contract for data layer
abstract class IBudgetPlanRepository
    extends
        ICrudRepository<
          SavingsPlanTable,
          $SavingsPlanTableTable,
          SavingsPlanTableCompanion,
          SvngPlnSavingsPlan
        > {
  IBudgetPlanRepository(AppDatabase db) : super(db, db.savingsPlanTable);
  // ============================================================================
  // CRUD Operations for Budget Plans
  // ============================================================================

  /// Watch all budget plans (stream)
  Stream<List<BudgetPlanEntity>> watchAllPlans();

  /// Watch a single plan by UUID (stream)
  Stream<BudgetPlanEntity?> watchPlanById(String uuid);

  /// Get all budget plans (one-time)
  Future<List<BudgetPlanEntity>> getAllPlans();

  /// Get plan by UUID (one-time)
  Future<BudgetPlanEntity?> getPlanByUuid(String uuid);

  /// Create a new budget plan
  Future<BudgetPlanEntity> createPlan(CreateBudgetPlanParams params);

  /// Update an existing budget plan
  Future<void> updatePlan(String uuid, UpdateBudgetPlanParams params);

  /// Delete a budget plan
  Future<void> deletePlan(String uuid);

  /// Update plan status
  Future<void> updatePlanStatus(String uuid, BudgetPlanStatus status);

  // ============================================================================
  // Deposit Operations
  // ============================================================================

  /// Watch deposits for a plan (stream)
  Stream<List<BudgetPlanDepositEntity>> watchDeposits(String planUuid);

  /// Get deposits for a plan (one-time)
  Future<List<BudgetPlanDepositEntity>> getDeposits(String planUuid);

  /// Add a deposit to a plan
  Future<BudgetPlanDepositEntity> addDeposit(
    String planUuid,
    AddDepositParams params,
  );

  /// Delete a deposit
  Future<void> deleteDeposit(String depositUuid);

  // ============================================================================
  // Transaction (Spending) Operations
  // ============================================================================

  /// Watch transactions for a plan (stream)
  Stream<List<BudgetPlanTransactionEntity>> watchPlanTransactions(
    String planUuid,
  );

  /// Get transactions for a plan (one-time)
  Future<List<BudgetPlanTransactionEntity>> getPlanTransactions(
    String planUuid,
  );

  /// Add a spending transaction to a plan
  Future<BudgetPlanTransactionEntity> addPlanTransaction(
    String planUuid,
    AddPlanTransactionParams params,
  );

  /// Link an existing transaction to a plan
  Future<void> linkExistingTransaction(String planUuid, String transactionUuid);

  /// Unlink a transaction from a plan
  Future<void> unlinkTransaction(String planUuid, String transactionUuid);

  /// Delete a plan transaction
  Future<void> deletePlanTransaction(String transactionUuid);

  // ============================================================================
  // Linked Account Operations
  // ============================================================================

  /// Watch linked accounts for a plan (stream)
  Stream<List<LinkedAccountSummaryEntity>> watchLinkedAccounts(String planUuid);

  /// Link an account to a plan
  Future<void> linkAccount(
    String planId,
    String accountId, {
    double? allocatedPercentage,
  });

  /// Unlink an account from a plan
  Future<void> unlinkAccount(String planId, String accountId);

  // ============================================================================
  // Milestone Operations
  // ============================================================================

  /// Watch milestones for a plan (stream)
  Stream<List<BudgetPlanMilestoneEntity>> watchMilestones(String planUuid);

  /// Get milestones for a plan (one-time)
  Future<List<BudgetPlanMilestoneEntity>> getMilestones(String planUuid);

  /// Add a milestone to a plan
  Future<BudgetPlanMilestoneEntity> addMilestone(
    String planUuid,
    String title,
    double targetAmount,
    DateTime? dueDate,
  );

  /// Complete a milestone
  Future<void> completeMilestone(String milestoneId);

  /// Delete a milestone
  Future<void> deleteMilestone(String milestoneId);

  // ============================================================================
  // Analytics Operations
  // ============================================================================

  /// Get progress history for a plan
  Future<List<PlanProgressSnapshot>> getProgressHistory(String planUuid);

  /// Get spending by category for a plan
  Future<List<SpendingByCategory>> getSpendingByCategory(String planUuid);

  /// Get monthly contributions for a plan
  Future<List<MonthlyContribution>> getMonthlyContributions(String planUuid);

  /// Get complete analytics data for a plan
  Future<PlanAnalyticsData> getPlanAnalytics(String planUuid);

  // ============================================================================
  // Summary Operations
  // ============================================================================

  /// Get overall summary across all plans
  Future<BudgetPlanSummary> getOverallSummary();
}

/// Budget Plan Summary - aggregated data across all plans
class BudgetPlanSummary extends Equatable {
  final int totalPlans;
  final int activePlans;
  final int completedPlans;
  final int plansOnTrack;
  final int plansAtRisk;
  final double totalTargetAmount;
  final double totalSavedAmount;
  final double totalRemainingAmount;
  final double overallProgressPercentage;

  const BudgetPlanSummary({
    required this.totalPlans,
    required this.activePlans,
    required this.completedPlans,
    required this.plansOnTrack,
    required this.plansAtRisk,
    this.totalTargetAmount = 0,
    this.totalSavedAmount = 0,
    this.totalRemainingAmount = 0,
    this.overallProgressPercentage = 0,
  });

  @override
  List<Object?> get props => [
    totalPlans,
    activePlans,
    completedPlans,
    plansOnTrack,
    plansAtRisk,
    totalTargetAmount,
    totalSavedAmount,
    totalRemainingAmount,
    overallProgressPercentage,
  ];
}
