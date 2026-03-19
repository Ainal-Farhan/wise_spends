import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_deposit_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_transaction_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_milestone_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/linked_account_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_analytics.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/i_budget_plan_repository.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_params.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

/// Budget Plan Repository Implementation
/// Handles all database operations for savings plans
class BudgetPlanRepository extends IBudgetPlanRepository {
  BudgetPlanRepository() : super(AppDatabase());

  final AppDatabase _db = AppDatabase();

  @override
  String getTypeName() => 'SavingsPlanTable';

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
        .select(_db.savingsPlanTable)
        .watch()
        .map((rows) => rows.map((row) => _mapPlanToEntity(row)).toList());
  }

  @override
  Stream<BudgetPlanEntity?> watchPlanById(String id) {
    final query = _db.select(_db.savingsPlanTable)
      ..where((tbl) => tbl.id.equals(id));
    return query.watchSingleOrNull().map(
      (row) => row != null ? _mapPlanToEntity(row) : null,
    );
  }

  @override
  Future<List<BudgetPlanEntity>> getAllPlans() async {
    final query = _db.select(_db.savingsPlanTable);
    final rows = await query.get();
    final plans = rows.map(_mapPlanToEntity).toList();

    // Enrich each plan with calculated values (note: this makes multiple DB calls)
    // For better performance with many plans, consider batch calculation
    final enrichedPlans = <BudgetPlanEntity>[];
    for (final plan in plans) {
      enrichedPlans.add(await _enrichPlanWithCalculatedValues(plan));
    }

    return enrichedPlans;
  }

  @override
  Future<BudgetPlanEntity?> getPlanByUuid(String id) async {
    final query = _db.select(_db.savingsPlanTable)
      ..where((tbl) => tbl.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) return null;

    final plan = _mapPlanToEntity(rows.first);

    // Calculate totalDeposited and totalSpent asynchronously
    return await _enrichPlanWithCalculatedValues(plan);
  }

  /// Enrich plan with calculated totalDeposited and totalSpent values.
  ///
  /// ## Calculation semantics:
  /// - **totalDeposited** = manual deposits + item deposits (depositPaid)
  ///   Represents all money contributed/saved toward the plan.
  ///
  /// - **totalSpent** = manual spending + (item amountPaid only)
  ///   The [amountPaid] field represents payments beyond the initial deposit,
  ///   which are treated as "spending" from the plan's accumulated funds.
  ///
  /// Note: Item deposits (depositPaid) are NOT counted as spending because
  /// they represent the initial commitment, not ongoing withdrawals from savings.
  Future<BudgetPlanEntity> _enrichPlanWithCalculatedValues(
    BudgetPlanEntity plan,
  ) async {
    try {
      // Get total deposits from manual deposits
      final deposits = await getDeposits(plan.id);
      final totalManualDeposits = deposits.fold<double>(
        0.0,
        (sum, d) => sum + d.amount,
      );

      // Get total spending from manual spending
      final transactions = await getPlanTransactions(plan.id);
      final totalManualSpending = transactions.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      // Get items for this plan to calculate item-based totals
      final itemsQuery = _db.select(_db.savingsPlanItemTable)
        ..where((tbl) => tbl.planId.equals(plan.id));
      final items = await itemsQuery.get();

      // totalItemDepositsPaid: Sum of depositPaid across all items
      // Represents upfront deposits/commitments to vendors
      final totalItemDepositsPaid = items.fold<double>(
        0.0,
        (sum, i) => sum + i.depositPaid,
      );

      // totalItemAmountPaid: Sum of amountPaid across all items
      // Represents payments made toward the remaining balance AFTER the deposit
      // This is treated as "spending" from the plan's accumulated funds
      final totalItemAmountPaid = items.fold<double>(
        0.0,
        (sum, i) => sum + i.amountPaid,
      );

      // totalItemCommitment: Sum of totalCost across all items
      final totalItemCommitment = items.fold<double>(
        0.0,
        (sum, i) => sum + i.totalCost,
      );

      // totalItemOutstanding: Sum of outstanding amounts across all items
      final totalItemOutstanding = items.fold<double>(
        0.0,
        (sum, i) =>
            sum +
            (i.totalCost - i.depositPaid - i.amountPaid)
                .clamp(double.negativeInfinity, double.infinity)
                .abs(),
      );

      // totalDeposited = manual deposits + item deposits (depositPaid)
      // All money contributed/saved toward the plan
      final totalDeposited = totalManualDeposits + totalItemDepositsPaid;

      // totalSpent = manual spending + item amountPaid (payments beyond deposit)
      // The totalItemAmountPaid represents payments made BEYOND the deposit amount,
      // which are treated as withdrawals/spending from the plan's savings.
      final totalSpent = totalManualSpending + totalItemAmountPaid;

      return plan.copyWith(
        totalDeposited: totalDeposited,
        totalSpent: totalSpent,
        totalItemCommitment: totalItemCommitment,
        totalItemDepositPaid: totalItemDepositsPaid,
        totalItemAmountPaid: totalItemAmountPaid,
        totalItemOutstanding: totalItemOutstanding,
      );
    } catch (e) {
      // If calculation fails, return plan with default values
      return plan;
    }
  }

  @override
  Future<BudgetPlanEntity> createPlan(CreateBudgetPlanParams params) async {
    final id = const Uuid().v4();
    final companion = SavingsPlanTableCompanion.insert(
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
      createdBy: 'system',
      dateCreated: Value(DateTime.now()),
      dateUpdated: DateTime.now(),
      lastModifiedBy: 'system',
    );

    await _db.into(_db.savingsPlanTable).insert(companion);

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

    final updating = SavingsPlanTableCompanion(
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
      dateUpdated: Value(DateTime.now()),
      lastModifiedBy: Value('system'),
    );

    final query = _db.update(_db.savingsPlanTable)
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
      final query = _db.delete(_db.savingsPlanLinkedAccountTable)
        ..where((tbl) => tbl.planId.equals(plan.id));
      await query.go();
    }

    // Delete the plan
    final deleteQuery = _db.delete(_db.savingsPlanTable)
      ..where((tbl) => tbl.id.equals(id));
    await deleteQuery.go();
  }

  @override
  Future<void> updatePlanStatus(String id, BudgetPlanStatus status) async {
    final updating = SavingsPlanTableCompanion(
      status: Value(status.name),
      dateUpdated: Value(DateTime.now()),
      lastModifiedBy: Value('system'),
    );

    final query = _db.update(_db.savingsPlanTable)
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

    yield* (_db.select(_db.savingsPlanDepositTable)
          ..where((tbl) => tbl.planId.equals(plan.id)))
        .watch()
        .map((rows) => rows.map(_mapDepositToEntity).toList());
  }

  @override
  Future<List<BudgetPlanDepositEntity>> getDeposits(String planId) async {
    final query = _db.select(_db.savingsPlanDepositTable)
      ..where((tbl) => tbl.planId.equals(planId)); // use planId directly
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
    final companion = SavingsPlanDepositTableCompanion.insert(
      id: Value(id),
      planId: plan.id,
      amount: params.amount,
      note: Value(params.note),
      source: Value(params.source),
      depositDate: params.depositDate,
      linkedAccountId: Value(params.linkedAccountId),
      createdBy: 'system',
      dateCreated: Value(DateTime.now()),
      dateUpdated: DateTime.now(),
      lastModifiedBy: 'system',
    );

    await _db.into(_db.savingsPlanDepositTable).insert(companion);

    // If linkedAccountId is provided, create actual transaction and update allocation
    if (params.linkedAccountId != null) {
      await _createTransactionForLinkedDeposit(
        accountId: params.linkedAccountId!,
        amount: params.amount,
        description: params.note ?? 'Budget plan deposit',
        date: params.depositDate,
        planId: planId,
        budgetPlanDepositId: id,
      );

      // Increase allocation by the deposit amount
      await updateAllocation(planId, params.linkedAccountId!, params.amount);
    }

    // Recalculate plan's current amount using centralized method
    await recalculatePlanAmount(plan.id);

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
    // Get the deposit first to find the planId and linkedAccountId
    final deposit = await (db.select(
      db.savingsPlanDepositTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (deposit != null) {
      // Reverse linked account effects before deleting
      if (deposit.linkedAccountId != null) {
        await _reverseLinkedDepositEffect(
          planId: deposit.planId,
          accountId: deposit.linkedAccountId!,
          amount: deposit.amount,
        );
      }

      final query = db.delete(db.savingsPlanDepositTable)
        ..where((tbl) => tbl.id.equals(id));
      await query.go();

      // Recalculate plan's current amount using centralized method
      await recalculatePlanAmount(deposit.planId);
    }
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

    yield* (_db.select(_db.savingsPlanSpendingTable)
          ..where((tbl) => tbl.planId.equals(plan.id)))
        .watch()
        .map((rows) => rows.map(_mapTransactionToEntity).toList());
  }

  @override
  Future<List<BudgetPlanTransactionEntity>> getPlanTransactions(
    String planId,
  ) async {
    final query = _db.select(_db.savingsPlanSpendingTable)
      ..where((tbl) => tbl.planId.equals(planId)); // use planId directly
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

    // Validate spending doesn't exceed allocation if linked account is provided
    if (params.linkedAccountId != null) {
      final hasEnoughAllocation = await canSpend(
        planId,
        params.linkedAccountId!,
        params.amount,
      );
      if (!hasEnoughAllocation) {
        final allocation = await getAllocation(planId, params.linkedAccountId!);
        throw Exception(
          'Spending amount exceeds available allocation. Available: RM ${allocation.toStringAsFixed(2)}',
        );
      }
    }

    final id = const Uuid().v4();
    final companion = SavingsPlanSpendingTableCompanion.insert(
      id: Value(id),
      planId: plan.id,
      amount: params.amount,
      description: Value(params.description),
      vendor: Value(params.vendor),
      receiptImagePath: Value(params.receiptImagePath),
      spendingDate: params.transactionDate,
      createdBy: 'system',
      dateCreated: Value(DateTime.now()),
      dateUpdated: DateTime.now(),
      lastModifiedBy: 'system',
    );

    await _db.into(_db.savingsPlanSpendingTable).insert(companion);

    // If linkedAccountId is provided, create actual transaction and update allocation
    if (params.linkedAccountId != null) {
      await _createTransactionForLinkedAccount(
        accountId: params.linkedAccountId!,
        amount: params.amount,
        description:
            params.description ?? params.vendor ?? 'Budget plan spending',
        date: params.transactionDate,
        planId: planId,
        budgetPlanSpendingId: id,
      );

      // Decrease allocation by the spending amount
      await updateAllocation(planId, params.linkedAccountId!, -params.amount);
    }

    // Recalculate plan's current amount using centralized method
    await recalculatePlanAmount(plan.id);

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

  /// Create a transaction in the main transaction table for linked account spending
  Future<void> _createTransactionForLinkedAccount({
    required String accountId,
    required double amount,
    required String description,
    required DateTime date,
    required String planId,
    required String budgetPlanSpendingId,
  }) async {
    final transactionId = const Uuid().v4();

    // Create transaction in main transactions table as budget plan expense
    await _db
        .into(_db.transactionTable)
        .insert(
          TransactionTableCompanion.insert(
            id: Value(transactionId),
            type: TransactionType.budgetPlanExpense,
            description: Value(description),
            amount: amount,
            savingId: accountId,
            destinationSavingId: const Value(null),
            categoryId: const Value(null),
            commitmentTaskId: const Value(null),
            payeeId: const Value(null),
            transactionDateTime: Value(date),
            note: Value('Budget Plan: $planId'),
            createdBy: 'system',
            dateCreated: Value(DateTime.now()),
            dateUpdated: DateTime.now(),
            lastModifiedBy: 'system',
          ),
        );

    // Update the savings account balance (deduct the amount)
    await _updateSavingAccountBalance(accountId, -amount);
  }

  /// Create a transaction in the main transaction table for linked account deposit
  Future<void> _createTransactionForLinkedDeposit({
    required String accountId,
    required double amount,
    required String description,
    required DateTime date,
    required String planId,
    required String budgetPlanDepositId,
  }) async {
    final transactionId = const Uuid().v4();

    // Create transaction in main transactions table as budget plan income
    await _db
        .into(_db.transactionTable)
        .insert(
          TransactionTableCompanion.insert(
            id: Value(transactionId),
            type: TransactionType.budgetPlanDeposit,
            description: Value(description),
            amount: amount,
            savingId: accountId,
            destinationSavingId: const Value(null),
            categoryId: const Value(null),
            commitmentTaskId: const Value(null),
            payeeId: const Value(null),
            transactionDateTime: Value(date),
            note: Value('Budget Plan Deposit: $planId'),
            createdBy: 'system',
            dateCreated: Value(DateTime.now()),
            dateUpdated: DateTime.now(),
            lastModifiedBy: 'system',
          ),
        );

    // Update the savings account balance (add the amount)
    await _updateSavingAccountBalance(accountId, amount);
  }

  /// Update savings account balance by a delta amount
  Future<void> _updateSavingAccountBalance(
    String accountId,
    double delta,
  ) async {
    final saving = await (_db.select(
      _db.savingTable,
    )..where((tbl) => tbl.id.equals(accountId))).getSingleOrNull();

    if (saving != null) {
      final newBalance = saving.currentAmount + delta;
      final updating = SavingTableCompanion(
        currentAmount: Value(newBalance),
        dateUpdated: Value(DateTime.now()),
      );
      final query = _db.update(_db.savingTable)
        ..where((tbl) => tbl.id.equals(accountId));
      await query.write(updating);
    }
  }

  /// Reverse the effects of a linked deposit when it's deleted.
  ///
  /// This method:
  /// 1. Credits the savings account balance back (reverse of the original debit)
  /// 2. Decreases the allocation by the deposit amount
  ///
  /// Called by [deleteDeposit] when a linked deposit is removed.
  Future<void> _reverseLinkedDepositEffect({
    required String planId,
    required String accountId,
    required double amount,
  }) async {
    // Credit the savings account balance back (reverse of original debit)
    // Original deposit deducted from account, so we add it back
    await _updateSavingAccountBalance(accountId, amount);

    // Decrease allocation by the deposit amount (reverse of the increase)
    await updateAllocation(planId, accountId, -amount);
  }

  /// Reverse the effects of a linked spending when it's deleted.
  ///
  /// This method:
  /// 1. Credits the savings account balance back (reverse of the original debit)
  /// 2. Increases the allocation by the spending amount
  ///
  /// Called by [deletePlanTransaction] when a linked spending is removed.
  Future<void> _reverseLinkedSpendingEffect({
    required String planId,
    required String accountId,
    required double amount,
  }) async {
    // Credit the savings account balance back (reverse of original debit)
    // Original spending deducted from account, so we add it back
    await _updateSavingAccountBalance(accountId, amount);

    // Increase allocation by the spending amount (reverse of the decrease)
    await updateAllocation(planId, accountId, amount);
  }

  @override
  Future<void> linkExistingTransaction(
    String planId,
    String transactionId,
  ) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    // Update the transactionId in budget_plan_transactions
    final companion = SavingsPlanSpendingTableCompanion.insert(
      id: Value(const Uuid().v4()),
      planId: plan.id,
      transactionId: Value(transactionId),
      amount: 0, // Should be populated from actual transaction
      spendingDate: DateTime.now(),
      createdBy: 'system',
      dateCreated: Value(DateTime.now()),
      dateUpdated: DateTime.now(),
      lastModifiedBy: 'system',
    );
    await _db.into(_db.savingsPlanSpendingTable).insert(companion);
  }

  @override
  Future<void> unlinkTransaction(String planId, String transactionId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final query = _db.delete(_db.savingsPlanSpendingTable)
      ..where(
        (tbl) =>
            tbl.planId.equals(plan.id) &
            tbl.transactionId.equals(transactionId),
      );
    await query.go();
  }

  @override
  Future<void> deletePlanTransaction(String id) async {
    // Get the transaction first to find the planId
    final transaction = await (db.select(
      db.savingsPlanSpendingTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (transaction != null) {
      // Reverse linked account effects before deleting
      final transactionId = transaction.transactionId;
      if (transactionId != null) {
        // Find the linked account for this spending by looking up the main transaction
        final mainTransaction = await (db.select(
          db.transactionTable,
        )..where((tbl) => tbl.id.equals(transactionId))).getSingleOrNull();

        if (mainTransaction != null) {
          await _reverseLinkedSpendingEffect(
            planId: transaction.planId,
            accountId: mainTransaction.savingId,
            amount: transaction.amount,
          );
        }
      }

      final query = db.delete(db.savingsPlanSpendingTable)
        ..where((tbl) => tbl.id.equals(id));
      await query.go();

      // Recalculate plan's current amount using centralized method
      await recalculatePlanAmount(transaction.planId);
    }
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

    final stream = _db.select(_db.savingsPlanLinkedAccountTable)
      ..where((tbl) => tbl.planId.equals(plan.id));

    await for (final rows in stream.watch()) {
      final accounts = <LinkedAccountSummaryEntity>[];

      for (final row in rows) {
        // Join to get real account name and balance
        final saving = await (_db.select(
          _db.savingTable,
        )..where((t) => t.id.equals(row.accountId))).getSingleOrNull();

        accounts.add(
          LinkedAccountSummaryEntity(
            id: row.id,
            planId: row.planId,
            accountId: row.accountId,
            accountName: saving?.name ?? 'Account ${row.accountId}',
            accountType: saving?.type ?? 'Linked',
            accountBalance: saving?.currentAmount ?? 0.0,
            allocatedAmount: row.allocatedAmount ?? 0.0,
            linkedAt: row.linkedAt,
          ),
        );
      }

      yield accounts;
    }
  }

  @override
  Stream<List<SvngPlnLinkedAccount>> watchLinkedAccountsByAccountId(
    String accountId,
  ) {
    final stream = _db.select(_db.savingsPlanLinkedAccountTable)
      ..where((tbl) => tbl.accountId.equals(accountId));

    return stream.watch();
  }

  @override
  Future<void> linkAccount(
    String planId,
    String accountId,
    double allocatedAmount,
  ) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final id = const Uuid().v4();
    final companion = SavingsPlanLinkedAccountTableCompanion.insert(
      id: Value(id),
      planId: plan.id,
      accountId: accountId,
      allocatedAmount: Value(allocatedAmount),
      createdBy: 'system',
      dateCreated: Value(DateTime.now()),
      dateUpdated: DateTime.now(),
      lastModifiedBy: 'system',
    );

    await _db.into(_db.savingsPlanLinkedAccountTable).insert(companion);

    // Recalculate plan's current amount using centralized method
    await recalculatePlanAmount(plan.id);
  }

  @override
  Future<void> unlinkAccount(String planId, String accountId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) throw Exception('Plan not found');

    final query = _db.delete(_db.savingsPlanLinkedAccountTable)
      ..where(
        (tbl) => tbl.planId.equals(plan.id) & tbl.accountId.equals(accountId),
      );
    await query.go();

    // Recalculate plan's current amount using centralized method
    await recalculatePlanAmount(plan.id);
  }

  @override
  Future<void> updateAllocation(
    String planId,
    String accountId,
    double deltaAmount,
  ) async {
    // Get current allocation
    final currentAllocation = await getAllocation(planId, accountId);
    final newAllocation = currentAllocation + deltaAmount;

    // Prevent negative allocations - this indicates a logic error
    // Allocation should be allowed to reach zero (nothing reserved),
    // but never go negative. If this throws, check that deposits/spending
    // are properly reversed on delete.
    if (newAllocation < 0) {
      throw StateError(
        'Allocation cannot be negative. Attempted to update allocation for '
        'plan $planId and account $accountId from ${currentAllocation.toStringAsFixed(2)} '
        'by ${deltaAmount.toStringAsFixed(2)} to ${newAllocation.toStringAsFixed(2)}. '
        'This may indicate a missing reversal operation on delete.',
      );
    }

    // Update the allocation amount
    // Note: allocatedAmount can be zero (nothing currently reserved for this plan)
    // but the account remains linked. Only explicit unlinkAccount() calls should
    // remove the link.
    final updating = SavingsPlanLinkedAccountTableCompanion(
      allocatedAmount: Value(newAllocation),
      dateUpdated: Value(DateTime.now()),
      lastModifiedBy: Value('system'),
    );

    final query = _db.update(_db.savingsPlanLinkedAccountTable)
      ..where(
        (tbl) => tbl.planId.equals(planId) & tbl.accountId.equals(accountId),
      );
    await query.write(updating);
  }

  @override
  Future<double> getAllocation(String planId, String accountId) async {
    final account =
        await (_db.select(_db.savingsPlanLinkedAccountTable)..where(
              (tbl) =>
                  tbl.planId.equals(planId) & tbl.accountId.equals(accountId),
            ))
            .getSingleOrNull();

    return account?.allocatedAmount ?? 0.0;
  }

  @override
  Future<void> syncAllocatedAmountWithBalance(String accountId) async {
    try {
      // Get current saving balance
      final savingService = SingletonUtil.getSingleton<IServiceLocator>()!
          .getSavingService();
      final saving = await savingService.watchSavingById(accountId).first;
      final currentBalance = saving?.currentAmount ?? 0.0;
      final Set<String> planUuids = {};

      // Get all linked accounts for this saving
      final linkedAccounts = await watchLinkedAccountsByAccountId(
        accountId,
      ).first;

      // For each linked account, sync the allocated amount
      for (final linkedAccount in linkedAccounts) {
        final allocatedAmount = linkedAccount.allocatedAmount ?? 0.0;

        // If current balance is less than allocated, reduce the allocation
        if (currentBalance < allocatedAmount) {
          final newAllocatedAmount = currentBalance < 0
              ? 0.0
              : currentBalance.toDouble();

          // Update the allocation
          final updating = SavingsPlanLinkedAccountTableCompanion(
            allocatedAmount: Value(newAllocatedAmount),
            dateUpdated: Value(DateTime.now()),
            lastModifiedBy: Value('system'),
          );

          planUuids.add(linkedAccount.planId);

          final query = _db.update(_db.savingsPlanLinkedAccountTable)
            ..where(
              (tbl) =>
                  tbl.planId.equals(linkedAccount.planId) &
                  tbl.accountId.equals(accountId),
            );
          await query.write(updating);
        }
      }

      if (planUuids.isNotEmpty) {
        for (var planId in planUuids) {
          await recalculatePlanAmount(planId);
        }
      }
    } catch (e, stackTrace) {
      WiseLogger().error(
        'Error syncing allocated amount with balance: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if spending would exceed allocation
  Future<bool> canSpend(String planId, String accountId, double amount) async {
    final allocation = await getAllocation(planId, accountId);
    return amount <= allocation;
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

    yield* (_db.select(_db.savingsPlanMilestoneTable)
          ..where((tbl) => tbl.planId.equals(plan.id)))
        .watch()
        .map((rows) => rows.map(_mapMilestoneToEntity).toList());
  }

  @override
  Future<List<BudgetPlanMilestoneEntity>> getMilestones(String planId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) return [];

    final query = _db.select(_db.savingsPlanMilestoneTable)
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
    final companion = SavingsPlanMilestoneTableCompanion.insert(
      id: Value(id),
      planId: plan.id,
      title: title,
      targetAmount: targetAmount,
      dueDate: Value(dueDate),
      isCompleted: const Value(false),
      createdBy: 'system',
      dateCreated: Value(DateTime.now()),
      dateUpdated: DateTime.now(),
      lastModifiedBy: 'system',
    );

    await _db.into(_db.savingsPlanMilestoneTable).insert(companion);

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
    final updating = SavingsPlanMilestoneTableCompanion(
      isCompleted: const Value(true),
      completedAt: Value(DateTime.now()),
      dateUpdated: Value(DateTime.now()),
      lastModifiedBy: Value('system'),
    );

    final query = _db.update(_db.savingsPlanMilestoneTable)
      ..where((tbl) => tbl.id.equals(milestoneId));
    await query.write(updating);
  }

  @override
  Future<void> deleteMilestone(String milestoneId) async {
    final query = _db.delete(_db.savingsPlanMilestoneTable)
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
      (s, p) => s + p.targetAmount,
    );
    final totalSavedAmount = plans.fold<double>(
      0.0,
      (s, p) => s + p.currentAmount,
    );
    final totalRemainingAmount = totalTargetAmount - totalSavedAmount;
    final overallProgressPercentage = totalTargetAmount > 0
        ? ((totalSavedAmount / totalTargetAmount) * 100).toDouble()
        : 0.0;

    // ── New item aggregations (no extra DB calls needed) ──────────────
    final totalSpent = plans.fold<double>(0.0, (s, p) => s + p.totalSpent);
    final totalItemCost = plans.fold<double>(
      0.0,
      (s, p) => s + p.totalItemCommitment,
    );
    final totalItemPaid = plans.fold<double>(
      0.0,
      (s, p) => s + p.totalItemDepositPaid + p.totalItemAmountPaid,
    );
    final totalItemOutstanding = plans.fold<double>(
      0.0,
      (s, p) => s + p.totalItemOutstanding,
    );

    // Item counts — derived from per-plan item fields
    // totalItemCommitment > 0 means plan has items
    // outstanding == commitment means nothing paid yet (unpaid)
    // outstanding > 0 && outstanding < commitment means partial
    final totalItemCount = plans.fold<int>(0, (s, p) {
      // We don't have per-item count on entity yet so track plans-with-items
      return s + (p.totalItemCommitment > 0 ? 1 : 0);
    });
    final unpaidItemCount = plans.fold<int>(0, (s, p) {
      final paid = p.totalItemDepositPaid + p.totalItemAmountPaid;
      return s + (p.totalItemCommitment > 0 && paid == 0 ? 1 : 0);
    });
    final partialItemCount = plans.fold<int>(0, (s, p) {
      final paid = p.totalItemDepositPaid + p.totalItemAmountPaid;
      return s + (paid > 0 && p.totalItemOutstanding > 0 ? 1 : 0);
    });

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
      totalSpent: totalSpent,
      totalItemCost: totalItemCost,
      totalItemPaid: totalItemPaid,
      totalItemOutstanding: totalItemOutstanding,
      totalItemCount: totalItemCount,
      unpaidItemCount: unpaidItemCount,
      partialItemCount: partialItemCount,
    );
  }

  // ============================================================================
  // Recalculation Operations
  // ============================================================================

  @override
  Future<void> recalculateAmounts() async {
    final plans = await getAllPlans();
    for (final plan in plans) {
      await recalculatePlanAmount(plan.id);
    }
  }

  @override
  Future<void> recalculatePlanAmount(String planId) async {
    await _updatePlanCurrentAmount(planId);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Update plan's current amount based on deposits, transactions, item payments,
  /// and allocated amounts from linked accounts.
  Future<void> _updatePlanCurrentAmount(String planId) async {
    final plan = await getPlanByUuid(planId);
    if (plan == null) {
      return;
    }

    // Get total deposits from manual deposits (excluding linked account auto-deposits)
    final depositsQuery = _db.select(_db.savingsPlanDepositTable)
      ..where((tbl) => tbl.planId.equals(planId))
      ..where((tbl) => tbl.source.isNotValue('linked_account'));
    final deposits = await depositsQuery.get();
    final totalDeposits = deposits.fold<double>(
      0.0,
      (sum, d) => sum + d.amount,
    );

    // Get total allocated amounts from linked accounts
    final linkedAccountsQuery = _db.select(_db.savingsPlanLinkedAccountTable)
      ..where((tbl) => tbl.planId.equals(planId));
    final linkedAccounts = await linkedAccountsQuery.get();
    final totalAllocated = linkedAccounts.fold<double>(
      0.0,
      (sum, a) => sum + (a.allocatedAmount ?? 0.0),
    );

    // Total collected = manual deposits + linked account allocations
    final currentAmount = totalDeposits + totalAllocated;

    // Get total cost of all items in the plan
    final itemsQuery = _db.select(_db.savingsPlanItemTable)
      ..where((tbl) => tbl.planId.equals(planId));
    final items = await itemsQuery.get();
    final totalItemCost = items.fold<double>(
      0.0,
      (sum, i) => sum + i.totalCost,
    );

    // Target anchored to totalItemCost, never below currentAmount, never more than 10% above totalItemCost
    final targetAmount = totalItemCost.clamp(
      currentAmount,
      totalItemCost * 1.1,
    );

    final updating = SavingsPlanTableCompanion(
      currentAmount: Value(currentAmount),
      targetAmount: Value(targetAmount),
      dateUpdated: Value(DateTime.now()),
      lastModifiedBy: Value('system'),
    );

    final query = _db.update(_db.savingsPlanTable)
      ..where((tbl) => tbl.id.equals(planId));
    await query.write(updating);
  }

  /// Map database row to BudgetPlanEntity
  BudgetPlanEntity _mapPlanToEntity(SvngPlnSavingsPlan row) {
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
      totalSpent: 0, // Will be calculated asynchronously in getPlanByUuid
      totalDeposited: 0, // Will be calculated asynchronously in getPlanByUuid
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
      updatedAt: row.dateUpdated,
    );
  }

  /// Map database row to BudgetPlanDepositEntity
  BudgetPlanDepositEntity _mapDepositToEntity(SvngPlnDeposit row) {
    return BudgetPlanDepositEntity(
      id: row.id,
      planId: row.planId,
      amount: row.amount,
      note: row.note,
      source: row.source ?? 'manual',
      depositDate: row.depositDate,
      linkedAccountId: row.linkedAccountId,
      createdAt: row.dateCreated,
    );
  }

  /// Map database row to BudgetPlanTransactionEntity
  BudgetPlanTransactionEntity _mapTransactionToEntity(SvngPlnSpending row) {
    return BudgetPlanTransactionEntity(
      id: row.id,
      planId: row.planId,
      transactionId: row.transactionId,
      amount: row.amount,
      description: row.description,
      vendor: row.vendor,
      transactionDate: row.spendingDate,
      createdAt: row.dateCreated,
    );
  }

  /// Map database row to BudgetPlanMilestoneEntity
  BudgetPlanMilestoneEntity _mapMilestoneToEntity(SvngPlnMilestone row) {
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

  @override
  Future<List<SavingVO>> getAvailableSavingsAccounts(String planId) async {
    final linkedIds = db.selectOnly(db.savingsPlanLinkedAccountTable)
      ..addColumns([db.savingsPlanLinkedAccountTable.accountId])
      ..where(db.savingsPlanLinkedAccountTable.planId.equals(planId));

    final result = await (db.select(
      db.savingTable,
    )..where((t) => t.id.isNotInQuery(linkedIds))).get();

    return result.map((s) => SavingVO.fromSvngSaving(s)).toList();
  }

  @override
  SvngPlnSavingsPlan fromJson(Map<String, dynamic> json) =>
      SvngPlnSavingsPlan.fromJson(json);
}
