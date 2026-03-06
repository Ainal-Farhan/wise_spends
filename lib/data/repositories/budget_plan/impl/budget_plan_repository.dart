import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_deposit_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_transaction_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_milestone_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/linked_account_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_analytics.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_params.dart';

/// Budget Plan Repository Implementation
/// Handles all database operations for budget plans
class BudgetPlanRepository extends IBudgetPlanRepository {
  final AppDatabase _db = AppDatabase();

  @override
  void dispose() {
    // No resources to dispose
  }

  // ============================================================================
  // CRUD Operations for Budget Plans
  // ============================================================================

  @override
  Stream<List<BudgetPlanEntity>> watchAllPlans() {
    return _db
        .select(_db.budgetPlans)
        .watch()
        .map((rows) => rows.map((row) => _mapPlanToEntity(row)).toList());
  }

  @override
  Stream<BudgetPlanEntity?> watchPlanById(String id) {
    final query = _db.select(_db.budgetPlans)
      ..where((tbl) => tbl.id.equals(id));
    return query.watchSingleOrNull().map(
      (row) => row != null ? _mapPlanToEntity(row) : null,
    );
  }

  @override
  Future<List<BudgetPlanEntity>> getAllPlans() async {
    final query = _db.select(_db.budgetPlans);
    final rows = await query.get();
    return rows.map(_mapPlanToEntity).toList();
  }

  @override
  Future<BudgetPlanEntity?> getPlanByUuid(String id) async {
    final query = _db.select(_db.budgetPlans)
      ..where((tbl) => tbl.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _mapPlanToEntity(rows.first);
  }

  @override
  Future<BudgetPlanEntity> createPlan(CreateBudgetPlanParams params) async {
    final id = const Uuid().v4();
    final companion = BudgetPlansCompanion.insert(
      id: Value(id),
      name: params.name,
      description: Value(params.description),
      category: params.category.name,
      targetAmount: params.targetAmount,
      currency: Value(params.currency),
      startDate: params.startDate,
      targetDate: params.targetDate,
      iconCode: Value(params.iconCode),
      colorHex: Value(params.colorHex),
      currentAmount: const Value(0.0),
      status: const Value('active'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await _db.into(_db.budgetPlans).insert(companion);

    // Create milestones if provided
    if (params.milestones != null && params.milestones!.isNotEmpty) {
      for (final milestoneParams in params.milestones!) {
        await addMilestone(
          id,
          milestoneParams.title,
          milestoneParams.targetAmount,
          milestoneParams.dueDate,
        );
      }
    }

    return getPlanByUuid(id).then((plan) => plan!);
  }

  @override
  Future<void> updatePlan(String id, UpdateBudgetPlanParams params) async {
    final plan = await getPlanByUuid(id);
    if (plan == null) throw Exception('Plan not found');

    final updating = BudgetPlansCompanion(
      name: params.name != null ? Value(params.name!) : const Value.absent(),
      description: params.description != null
          ? Value(params.description!)
          : const Value.absent(),
      category: params.category != null
          ? Value(params.category!.name)
          : const Value.absent(),
      targetAmount: params.targetAmount != null
          ? Value(params.targetAmount!)
          : const Value.absent(),
      targetDate: params.targetDate != null
          ? Value(params.targetDate!)
          : const Value.absent(),
      iconCode: params.iconCode != null
          ? Value(params.iconCode!)
          : const Value.absent(),
      colorHex: params.colorHex != null
          ? Value(params.colorHex!)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    final query = _db.update(_db.budgetPlans)
      ..where((tbl) => tbl.id.equals(id));
    await query.write(updating);
  }

  @override
  Future<void> deletePlan(String id) async {
    // First delete all related data
    final plan = await getPlanByUuid(id);
    if (plan != null) {
      // Delete deposits
      final deposits = await getDeposits(id);
      for (final deposit in deposits) {
        await deleteDeposit(deposit.id);
      }

      // Delete transactions
      final transactions = await getPlanTransactions(id);
      for (final transaction in transactions) {
        await deletePlanTransaction(transaction.id);
      }

      // Delete milestones
      final milestones = await getMilestones(id);
      for (final milestone in milestones) {
        await deleteMilestone(milestone.id);
      }

      // Delete linked accounts
      final query = _db.delete(_db.budgetPlanLinkedAccounts)
        ..where((tbl) => tbl.planId.equals(plan.id));
      await query.go();
    }

    // Delete the plan
    final deleteQuery = _db.delete(_db.budgetPlans)
      ..where((tbl) => tbl.id.equals(id));
    await deleteQuery.go();
  }

  @override
  Future<void> updatePlanStatus(String id, BudgetPlanStatus status) async {
    final updating = BudgetPlansCompanion(
      status: Value(status.name),
      updatedAt: Value(DateTime.now()),
    );

    final query = _db.update(_db.budgetPlans)
      ..where((tbl) => tbl.id.equals(id));
    await query.write(updating);
  }

  // ============================================================================
  // Deposit Operations
  // ============================================================================

  @override
  Stream<List<BudgetPlanDepositEntity>> watchDeposits(String planId) async* {
    final plan = await getPlanByUuid(planId);
    if (plan == null) {
      yield [];
      return;
    }

    yield* (_db.select(_db.budgetPlanDeposits)
          ..where((tbl) => tbl.planId.equals(plan.id)))
        .watch()
        .map((rows) => rows.map(_mapDepositToEntity).toList());
  }

  @override
  Future<List<BudgetPlanDepositEntity>> getDeposits(String planId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) return [];

    final query = _db.select(_db.budgetPlanDeposits)
      ..where((tbl) => tbl.planId.equals(plan.id));
    final rows = await query.get();
    return rows.map(_mapDepositToEntity).toList();
  }

  @override
  Future<BudgetPlanDepositEntity> addDeposit(
    String planId,
    AddDepositParams params,
  ) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final id = const Uuid().v4();
    final companion = BudgetPlanDepositsCompanion.insert(
      id: Value(id),
      planId: plan.id,
      amount: params.amount,
      note: Value(params.note),
      source: Value(params.source),
      depositDate: params.depositDate,
      linkedAccountId: Value(params.linkedAccountId),
      createdAt: Value(DateTime.now()),
    );

    await _db.into(_db.budgetPlanDeposits).insert(companion);

    // Update plan's current amount
    await _updatePlanCurrentAmount(plan.id);

    return BudgetPlanDepositEntity(
      id: id,
      planId: plan.id,
      amount: params.amount,
      note: params.note,
      source: params.source,
      depositDate: params.depositDate,
      linkedAccountId: params.linkedAccountId,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteDeposit(String id) async {
    final query = _db.delete(_db.budgetPlanDeposits)
      ..where((tbl) => tbl.id.equals(id));
    await query.go();

    // Update plan's current amount
    // (In a real implementation, we'd recalculate from remaining deposits)
  }

  // ============================================================================
  // Transaction (Spending) Operations
  // ============================================================================

  @override
  Stream<List<BudgetPlanTransactionEntity>> watchPlanTransactions(
    String planId,
  ) async* {
    final plan = await getPlanByUuid(planId);
    if (plan == null) {
      yield [];
      return;
    }

    yield* (_db.select(_db.budgetPlanTransactions)
          ..where((tbl) => tbl.planId.equals(plan.id)))
        .watch()
        .map((rows) => rows.map(_mapTransactionToEntity).toList());
  }

  @override
  Future<List<BudgetPlanTransactionEntity>> getPlanTransactions(
    String planId,
  ) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) return [];

    final query = _db.select(_db.budgetPlanTransactions)
      ..where((tbl) => tbl.planId.equals(plan.id));
    final rows = await query.get();
    return rows.map(_mapTransactionToEntity).toList();
  }

  @override
  Future<BudgetPlanTransactionEntity> addPlanTransaction(
    String planId,
    AddPlanTransactionParams params,
  ) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final id = const Uuid().v4();
    final companion = BudgetPlanTransactionsCompanion.insert(
      id: Value(id),
      planId: plan.id,
      amount: params.amount,
      description: Value(params.description),
      vendor: Value(params.vendor),
      receiptImagePath: Value(params.receiptImagePath),
      transactionDate: params.transactionDate,
      createdAt: Value(DateTime.now()),
    );

    await _db.into(_db.budgetPlanTransactions).insert(companion);

    // Update plan's current amount (subtract spending)
    await _updatePlanCurrentAmount(plan.id);

    return BudgetPlanTransactionEntity(
      id: id,
      planId: plan.id,
      amount: params.amount,
      description: params.description,
      vendor: params.vendor,
      transactionDate: params.transactionDate,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> linkExistingTransaction(
    String planId,
    String transactionId,
  ) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    // Update the transactionId in budget_plan_transactions
    final companion = BudgetPlanTransactionsCompanion.insert(
      id: Value(const Uuid().v4()),
      planId: plan.id,
      transactionId: Value(transactionId),
      amount: 0, // Should be populated from actual transaction
      transactionDate: DateTime.now(),
      createdAt: Value(DateTime.now()),
    );
    await _db.into(_db.budgetPlanTransactions).insert(companion);
  }

  @override
  Future<void> unlinkTransaction(String planId, String transactionId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final query = _db.delete(_db.budgetPlanTransactions)
      ..where(
        (tbl) =>
            tbl.planId.equals(plan.id) &
            tbl.transactionId.equals(transactionId),
      );
    await query.go();
  }

  @override
  Future<void> deletePlanTransaction(String id) async {
    final query = _db.delete(_db.budgetPlanTransactions)
      ..where((tbl) => tbl.id.equals(id));
    await query.go();

    // Update plan's current amount
  }

  // ============================================================================
  // Linked Account Operations
  // ============================================================================

  @override
  Stream<List<LinkedAccountSummaryEntity>> watchLinkedAccounts(
    String planId,
  ) async* {
    final plan = await getPlanByUuid(planId);
    if (plan == null) {
      yield [];
      return;
    }

    final stream = _db.select(_db.budgetPlanLinkedAccounts)
      ..where((tbl) => tbl.planId.equals(plan.id));

    await for (final rows in stream.watch()) {
      final accounts = <LinkedAccountSummaryEntity>[];

      for (final row in rows) {
        // Note: Full account table join requires schema updates
        // For now, return basic linked account info
        accounts.add(
          LinkedAccountSummaryEntity(
            id: row.id,
            planId: row.planId,
            accountId: row.accountId,
            accountName: 'Account ${row.accountId}',
            accountType: 'Linked',
            accountBalance:
                0, // Would require joining with actual account table
            allocatedPercentage: row.allocatedPercentage,
            allocatedAmount: 0, // Would require account balance
            linkedAt: row.linkedAt,
          ),
        );
      }

      yield accounts;
    }
  }

  @override
  Future<void> linkAccount(
    String planId,
    String accountId, {
    double? allocatedPercentage,
  }) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final id = const Uuid().v4();
    final companion = BudgetPlanLinkedAccountsCompanion.insert(
      id: Value(id),
      planId: plan.id,
      accountId: accountId,
      allocatedPercentage: Value(allocatedPercentage),
      linkedAt: Value(DateTime.now()),
    );

    await _db.into(_db.budgetPlanLinkedAccounts).insert(companion);
  }

  @override
  Future<void> unlinkAccount(String planId, String accountId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final query = _db.delete(_db.budgetPlanLinkedAccounts)
      ..where(
        (tbl) => tbl.planId.equals(plan.id) & tbl.accountId.equals(accountId),
      );
    await query.go();
  }

  // ============================================================================
  // Milestone Operations
  // ============================================================================

  @override
  Stream<List<BudgetPlanMilestoneEntity>> watchMilestones(
    String planId,
  ) async* {
    final plan = await getPlanByUuid(planId);
    if (plan == null) {
      yield [];
      return;
    }

    yield* (_db.select(_db.budgetPlanMilestones)
          ..where((tbl) => tbl.planId.equals(plan.id)))
        .watch()
        .map((rows) => rows.map(_mapMilestoneToEntity).toList());
  }

  @override
  Future<List<BudgetPlanMilestoneEntity>> getMilestones(String planId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) return [];

    final query = _db.select(_db.budgetPlanMilestones)
      ..where((tbl) => tbl.planId.equals(plan.id));
    final rows = await query.get();
    return rows.map(_mapMilestoneToEntity).toList();
  }

  @override
  Future<BudgetPlanMilestoneEntity> addMilestone(
    String planId,
    String title,
    double targetAmount,
    DateTime? dueDate,
  ) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final id = const Uuid().v4();
    final companion = BudgetPlanMilestonesCompanion.insert(
      id: Value(id),
      planId: plan.id,
      title: title,
      targetAmount: targetAmount,
      dueDate: Value(dueDate),
      isCompleted: const Value(false),
    );

    await _db.into(_db.budgetPlanMilestones).insert(companion);

    return BudgetPlanMilestoneEntity(
      id: id,
      planId: plan.id,
      title: title,
      targetAmount: targetAmount,
      dueDate: dueDate,
    );
  }

  @override
  Future<void> completeMilestone(String milestoneId) async {
    final updating = BudgetPlanMilestonesCompanion(
      isCompleted: const Value(true),
      completedAt: Value(DateTime.now()),
    );

    final query = _db.update(_db.budgetPlanMilestones)
      ..where((tbl) => tbl.id.equals(milestoneId));
    await query.write(updating);
  }

  @override
  Future<void> deleteMilestone(String milestoneId) async {
    final query = _db.delete(_db.budgetPlanMilestones)
      ..where((tbl) => tbl.id.equals(milestoneId));
    await query.go();
  }

  // ============================================================================
  // Analytics Operations
  // ============================================================================

  @override
  Future<List<PlanProgressSnapshot>> getProgressHistory(String planUuid) async {
    final plan = await getPlanByUuid(planUuid);
    if (plan == null) return [];

    // Get all deposits grouped by date
    final deposits = await getDeposits(planUuid);

    // Create cumulative snapshots
    final snapshots = <PlanProgressSnapshot>[];
    double cumulative = 0;

    // Group deposits by date and create snapshots
    final depositsByDate = <DateTime, double>{};
    for (final deposit in deposits) {
      final date = DateTime(
        deposit.depositDate.year,
        deposit.depositDate.month,
        deposit.depositDate.day,
      );
      depositsByDate[date] = (depositsByDate[date] ?? 0) + deposit.amount;
    }

    final sortedDates = depositsByDate.keys.toList()..sort();

    for (final date in sortedDates) {
      cumulative += depositsByDate[date]!;
      snapshots.add(
        PlanProgressSnapshot(
          date: date,
          amount: cumulative,
          targetAmount: plan.targetAmount,
          progressPercentage: (cumulative / plan.targetAmount).clamp(0.0, 1.0),
        ),
      );
    }

    return snapshots;
  }

  @override
  Future<List<SpendingByCategory>> getSpendingByCategory(
    String planUuid,
  ) async {
    final transactions = await getPlanTransactions(planUuid);

    if (transactions.isEmpty) return [];

    final totalSpent = transactions.fold<double>(0, (sum, t) => sum + t.amount);

    // Group by vendor or description (since we don't have categories yet)
    final byVendor = <String, double>{};
    for (final transaction in transactions) {
      final key = transaction.vendor ?? transaction.description ?? 'Other';
      byVendor[key] = (byVendor[key] ?? 0) + transaction.amount;
    }

    return byVendor.entries
        .map(
          (e) => SpendingByCategory(
            category: e.key,
            amount: e.value,
            percentage: (e.value / totalSpent) * 100,
          ),
        )
        .toList();
  }

  @override
  Future<List<MonthlyContribution>> getMonthlyContributions(
    String planUuid,
  ) async {
    final deposits = await getDeposits(planUuid);
    final transactions = await getPlanTransactions(planUuid);

    // Group by month using Map
    final byMonth = <String, Map<String, double>>{};

    for (final deposit in deposits) {
      final key =
          '${deposit.depositDate.year}-${deposit.depositDate.month.toString().padLeft(2, '0')}';
      if (!byMonth.containsKey(key)) {
        byMonth[key] = {'deposits': 0, 'spending': 0};
      }
      byMonth[key]!['deposits'] =
          (byMonth[key]!['deposits'] ?? 0) + deposit.amount;
    }

    for (final transaction in transactions) {
      final key =
          '${transaction.transactionDate.year}-${transaction.transactionDate.month.toString().padLeft(2, '0')}';
      if (!byMonth.containsKey(key)) {
        byMonth[key] = {'deposits': 0, 'spending': 0};
      }
      byMonth[key]!['spending'] =
          (byMonth[key]!['spending'] ?? 0) + transaction.amount;
    }

    // Convert to list
    final contributions = <MonthlyContribution>[];
    for (final entry in byMonth.entries) {
      final parts = entry.key.split('-');
      contributions.add(
        MonthlyContribution(
          year: int.parse(parts[0]),
          month: int.parse(parts[1]),
          deposits: entry.value['deposits'] ?? 0,
          spending: entry.value['spending'] ?? 0,
          net: (entry.value['deposits'] ?? 0) - (entry.value['spending'] ?? 0),
        ),
      );
    }

    // Sort by year and month
    contributions.sort((a, b) {
      if (a.year != b.year) return a.year.compareTo(b.year);
      return a.month.compareTo(b.month);
    });

    return contributions;
  }

  @override
  Future<PlanAnalyticsData> getPlanAnalytics(String planUuid) async {
    final deposits = await getDeposits(planUuid);
    final transactions = await getPlanTransactions(planUuid);
    final monthlyContributions = await getMonthlyContributions(planUuid);
    final progressHistory = await getProgressHistory(planUuid);
    final spendingByCategory = await getSpendingByCategory(planUuid);

    // Calculate averages
    final totalDeposited = deposits.fold<double>(0, (sum, d) => sum + d.amount);
    final totalSpent = transactions.fold<double>(0, (sum, t) => sum + t.amount);

    // Calculate months since first deposit
    final months = monthlyContributions.length;
    final averageMonthlyDeposit = months > 0
        ? totalDeposited / months.toDouble()
        : 0.0;
    final averageMonthlySpending = months > 0
        ? totalSpent / months.toDouble()
        : 0.0;

    // Calculate projected completion
    final plan = await getPlanByUuid(planUuid);
    String projectedCompletionLabel = 'Insufficient data';
    if (plan != null && averageMonthlyDeposit > 0) {
      final remaining = plan.targetAmount - plan.currentAmount;
      final monthsNeeded = remaining / averageMonthlyDeposit;
      final projectedDate = DateTime.now().add(
        Duration(days: (monthsNeeded * 30).round()),
      );
      projectedCompletionLabel =
          'On track for ${_getMonthName(projectedDate.month)} ${projectedDate.year}';
    }

    return PlanAnalyticsData(
      monthlyContributions: monthlyContributions,
      progressHistory: progressHistory,
      spendingByCategory: spendingByCategory,
      averageMonthlyDeposit: averageMonthlyDeposit,
      averageMonthlySpending: averageMonthlySpending,
      projectedCompletionLabel: projectedCompletionLabel,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // ============================================================================
  // Summary Operations
  // ============================================================================

  @override
  Future<BudgetPlanSummary> getOverallSummary() async {
    final plans = await getAllPlans();

    final totalPlans = plans.length;
    final activePlans = plans
        .where((p) => p.status == BudgetPlanStatus.active)
        .length;
    final completedPlans = plans
        .where((p) => p.status == BudgetPlanStatus.completed)
        .length;
    final plansOnTrack = plans
        .where((p) => p.healthStatus == BudgetHealthStatus.onTrack)
        .length;
    final plansAtRisk = plans
        .where(
          (p) =>
              p.healthStatus == BudgetHealthStatus.atRisk ||
              p.healthStatus == BudgetHealthStatus.slightlyBehind,
        )
        .length;

    final totalTargetAmount = plans.fold<double>(
      0.0,
      (sum, p) => sum + p.targetAmount,
    );
    final totalSavedAmount = plans.fold<double>(
      0.0,
      (sum, p) => sum + p.currentAmount,
    );
    final totalRemainingAmount = totalTargetAmount - totalSavedAmount;
    final overallProgressPercentage = totalTargetAmount > 0
        ? ((totalSavedAmount / totalTargetAmount) * 100).toDouble()
        : 0.0;

    return BudgetPlanSummary(
      totalPlans: totalPlans,
      activePlans: activePlans,
      completedPlans: completedPlans,
      plansOnTrack: plansOnTrack,
      plansAtRisk: plansAtRisk,
      totalTargetAmount: totalTargetAmount,
      totalSavedAmount: totalSavedAmount,
      totalRemainingAmount: totalRemainingAmount,
      overallProgressPercentage: overallProgressPercentage,
    );
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Update plan's current amount based on deposits and transactions
  Future<void> _updatePlanCurrentAmount(String planId) async {
    // Get total deposits
    final depositsQuery = _db.select(_db.budgetPlanDeposits)
      ..where((tbl) => tbl.planId.equals(planId));
    final deposits = await depositsQuery.get();
    final totalDeposits = deposits.fold<double>(
      0.0,
      (sum, d) => sum + d.amount,
    );

    // Get total spending
    final transactionsQuery = _db.select(_db.budgetPlanTransactions)
      ..where((tbl) => tbl.planId.equals(planId));
    final transactions = await transactionsQuery.get();
    final totalSpending = transactions.fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );

    // Update plan
    final currentAmount = totalDeposits - totalSpending;

    final updating = BudgetPlansCompanion(
      currentAmount: Value(currentAmount),
      updatedAt: Value(DateTime.now()),
    );

    final query = _db.update(_db.budgetPlans)
      ..where((tbl) => tbl.id.equals(planId));
    await query.write(updating);
  }

  /// Map database row to BudgetPlanEntity
  BudgetPlanEntity _mapPlanToEntity(BudgetPlan row) {
    return BudgetPlanEntity(
      id: row.id,
      name: row.name,
      description: row.description,
      category: BudgetPlanCategory.values.firstWhere(
        (c) => c.name == row.category,
        orElse: () => BudgetPlanCategory.custom,
      ),
      targetAmount: row.targetAmount,
      currentAmount: row.currentAmount,
      totalSpent: 0, // Would need calculation
      totalDeposited: 0, // Would need calculation
      currency: row.currency,
      startDate: row.startDate,
      targetDate: row.targetDate,
      status: BudgetPlanStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => BudgetPlanStatus.active,
      ),
      iconCode: row.iconCode,
      colorHex: row.colorHex,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Map database row to BudgetPlanDepositEntity
  BudgetPlanDepositEntity _mapDepositToEntity(BudgetPlanDeposit row) {
    return BudgetPlanDepositEntity(
      id: row.id,
      planId: row.planId,
      amount: row.amount,
      note: row.note,
      source: row.source ?? 'manual',
      depositDate: row.depositDate,
      linkedAccountId: row.linkedAccountId,
      createdAt: row.createdAt,
    );
  }

  /// Map database row to BudgetPlanTransactionEntity
  BudgetPlanTransactionEntity _mapTransactionToEntity(
    BudgetPlanTransaction row,
  ) {
    return BudgetPlanTransactionEntity(
      id: row.id,
      planId: row.planId,
      transactionId: row.transactionId,
      amount: row.amount,
      description: row.description,
      vendor: row.vendor,
      transactionDate: row.transactionDate,
      createdAt: row.createdAt,
    );
  }

  /// Map database row to BudgetPlanMilestoneEntity
  BudgetPlanMilestoneEntity _mapMilestoneToEntity(BudgetPlanMilestone row) {
    return BudgetPlanMilestoneEntity(
      id: row.id,
      planId: row.planId,
      title: row.title,
      targetAmount: row.targetAmount,
      isCompleted: row.isCompleted,
      dueDate: row.dueDate,
      completedAt: row.completedAt,
    );
  }
}
