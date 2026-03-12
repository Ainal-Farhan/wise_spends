import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';
import 'package:wise_spends/features/budget/data/repositories/i_budget_repository.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart';
import 'package:wise_spends/features/transaction/data/repositories/impl/transaction_repository.dart';
import 'package:wise_spends/features/category/data/repositories/impl/category_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'budget_event.dart';
import 'budget_state.dart';

/// Budget BLoC — manages budget state and business logic.
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final IBudgetRepository _repository;
  final ITransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  BudgetBloc(
    this._repository, {
    ITransactionRepository? transactionRepository,
    CategoryRepository? categoryRepository,
  }) : _transactionRepository =
           transactionRepository ?? TransactionRepository(),
       _categoryRepository = categoryRepository ?? CategoryRepository(),
       super(BudgetInitial()) {
    on<LoadBudgetsEvent>(_onLoadBudgets);
    on<LoadActiveBudgetsEvent>(_onLoadActiveBudgets);
    on<LoadBudgetsByCategoryEvent>(_onLoadBudgetsByCategory);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<UpdateBudgetSpentAmountEvent>(_onUpdateBudgetSpentAmount);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<DeleteMultipleBudgetsEvent>(_onDeleteMultipleBudgets);
    on<RefreshBudgetsEvent>(_onRefreshBudgets);
    on<ReloadBudgetsEvent>(_onReloadBudgets);
    on<FilterBudgetsByPeriodEvent>(_onFilterByPeriod);
    on<ClearBudgetFiltersEvent>(_onClearFilters);
    on<SyncBudgetSpentAmountEvent>(_onSyncBudgetSpentAmount);
    on<SyncAllBudgetsSpentAmountEvent>(_onSyncAllBudgetsSpentAmount);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LOAD HANDLERS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onLoadBudgets(
    LoadBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getAllBudgets();

      if (budgets.isEmpty) {
        emit(const BudgetEmpty('You haven\'t set any budgets yet'));
        return;
      }

      // Resolve category names for card subtitles. Failures are non-fatal.
      final categoryNames = <String, String>{};
      try {
        final uniqueCategoryIds = budgets.map((b) => b.categoryId).toSet();
        for (final id in uniqueCategoryIds) {
          final cat = await _categoryRepository.getCategoryById(id);
          if (cat != null) categoryNames[id] = cat.name;
        }
      } catch (e, stackTrace) {
        WiseLogger().debug(
          'Failed to resolve category names',
          tag: 'BudgetBloc',
          error: e,
          stackTrace: stackTrace,
        );
      }

      final activeCount = budgets.where((b) => b.isActive).length;
      final onTrackCount = budgets.where((b) => !b.isExceeded).length;

      emit(
        BudgetsLoaded(
          budgets: budgets,
          allBudgets: budgets,
          activeCount: activeCount,
          onTrackCount: onTrackCount,
          categoryNames: categoryNames,
        ),
      );
    } catch (e) {
      emit(BudgetError('Failed to load budgets: ${e.toString()}'));
    }
  }

  Future<void> _onLoadActiveBudgets(
    LoadActiveBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getActiveBudgets();

      if (budgets.isEmpty) {
        emit(const BudgetEmpty('No active budgets'));
        return;
      }

      emit(
        BudgetsLoaded(
          budgets: budgets,
          allBudgets: budgets,
          activeCount: budgets.length,
          onTrackCount: budgets.where((b) => !b.isExceeded).length,
        ),
      );
    } catch (e) {
      emit(BudgetError('Failed to load active budgets: ${e.toString()}'));
    }
  }

  Future<void> _onLoadBudgetsByCategory(
    LoadBudgetsByCategoryEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getBudgetsByCategory(event.categoryId);

      if (budgets.isEmpty) {
        emit(const BudgetEmpty('No budgets for this category'));
        return;
      }

      emit(
        BudgetsLoaded(
          budgets: budgets,
          allBudgets: budgets,
          activeCount: budgets.where((b) => b.isActive).length,
          onTrackCount: budgets.where((b) => !b.isExceeded).length,
        ),
      );
    } catch (e) {
      emit(BudgetError('Failed to load budgets: ${e.toString()}'));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CREATE / UPDATE / DELETE HANDLERS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onCreateBudget(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final now = DateTime.now();
      final budget = BudgetEntity(
        id: const Uuid().v4(),
        name: event.name,
        categoryId: event.categoryId,
        limitAmount: event.amount,
        spentAmount: 0,
        period: event.period,
        startDate: event.startDate,
        endDate: event.endDate,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final created = await _repository.createBudget(budget);
      emit(BudgetCreated(created));

      // Reload the full list after creation.
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to create budget: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final current = await _repository.getBudgetById(event.budgetId);
      if (current == null) {
        emit(const BudgetError('Budget not found'));
        return;
      }

      final updated = current.copyWith(
        name: event.name,
        limitAmount: event.amount,
        categoryId: event.categoryId,
        period: event.period,
        startDate: event.startDate,
        endDate: event.endDate,
        isActive: event.isActive,
        updatedAt: DateTime.now(),
      );

      final saved = await _repository.updateBudget(updated);
      emit(BudgetUpdated(saved));

      // Reload the full list after update.
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to update budget: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBudgetSpentAmount(
    UpdateBudgetSpentAmountEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final updated = await _repository.updateBudgetSpentAmount(
        event.budgetId,
        event.spentAmount,
      );
      emit(BudgetUpdated(updated));

      // Refresh the list so progress bars reflect the new amount.
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to update spent amount: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _repository.deleteBudget(event.budgetId);
      emit(BudgetDeleted(event.budgetId));

      // Reload the full list after deletion.
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to delete budget: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMultipleBudgets(
    DeleteMultipleBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      for (final id in event.budgetIds) {
        await _repository.deleteBudget(id);
      }
      emit(const BudgetDeleted('multiple'));

      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to delete budgets: ${e.toString()}'));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REFRESH HANDLERS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onRefreshBudgets(
    RefreshBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    // Pull-to-refresh: silently reload without showing a full loading spinner
    // so the RefreshIndicator handles the visual feedback.
    try {
      final budgets = await _repository.getAllBudgets();

      if (budgets.isEmpty) {
        emit(const BudgetEmpty('You haven\'t set any budgets yet'));
        return;
      }

      emit(
        BudgetsLoaded(
          budgets: budgets,
          allBudgets: budgets,
          activeCount: budgets.where((b) => b.isActive).length,
          onTrackCount: budgets.where((b) => !b.isExceeded).length,
        ),
      );
    } catch (e) {
      emit(BudgetError('Failed to refresh budgets: ${e.toString()}'));
    }
  }

  Future<void> _onReloadBudgets(
    ReloadBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    add(LoadBudgetsEvent());
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FILTER HANDLERS
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _onFilterByPeriod(
    FilterBudgetsByPeriodEvent event,
    Emitter<BudgetState> emit,
  ) async {
    final current = state;
    if (current is! BudgetsLoaded) return;

    try {
      // Filter against the full list so toggling never loses data.
      final source = current.allBudgets;

      final filtered = event.period == null
          ? source
          : source.where((b) => b.period == event.period).toList();

      emit(
        current.copyWith(
          budgets: filtered,
          activeCount: filtered.where((b) => b.isActive).length,
          onTrackCount: filtered.where((b) => !b.isExceeded).length,
          filterPeriod: event.period,
          clearFilter: event.period == null,
        ),
      );
    } catch (e) {
      emit(BudgetError('Failed to filter budgets: ${e.toString()}'));
    }
  }

  Future<void> _onClearFilters(
    ClearBudgetFiltersEvent event,
    Emitter<BudgetState> emit,
  ) async {
    final current = state;
    if (current is! BudgetsLoaded) {
      // If we're not in a loaded state, do a full reload instead.
      add(LoadBudgetsEvent());
      return;
    }

    // Restore the full unfiltered list without a DB round-trip.
    final all = current.allBudgets;
    emit(
      current.copyWith(
        budgets: all,
        activeCount: all.where((b) => b.isActive).length,
        onTrackCount: all.where((b) => !b.isExceeded).length,
        clearFilter: true,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SYNC HANDLER
  // ─────────────────────────────────────────────────────────────────────────

  /// Recalculates spentAmount for every active budget whose category matches
  /// the changed transaction and whose date window contains the transaction date.
  ///
  /// Algorithm:
  ///   1. Load all active budgets for the category.
  ///   2. For each matching budget, fetch all expense transactions in the
  ///      budget's [startDate, endDate] window for the same category.
  ///   3. Sum their amounts and persist via updateBudgetSpentAmount.
  ///   4. Reload the list so progress bars update immediately.
  Future<void> _onSyncBudgetSpentAmount(
    SyncBudgetSpentAmountEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      // Find every active budget for this category.
      final budgets = await _repository.getBudgetsByCategory(event.categoryId);
      final activeBudgets = budgets.where((b) => b.isActive).toList();

      if (activeBudgets.isEmpty) return;

      for (final budget in activeBudgets) {
        // Only sync budgets whose date window covers the transaction date.
        final endDate = budget.endDate ?? DateTime(9999);
        final isInWindow =
            !event.transactionDate.isBefore(budget.startDate) &&
            !event.transactionDate.isAfter(endDate);
        if (!isInWindow) continue;

        // Sum all expense transactions for this category in the budget window.
        final transactions = await _transactionRepository.fetchByDateRange(
          from: budget.startDate,
          to: endDate == DateTime(9999) ? DateTime.now() : endDate,
        );

        final spent = transactions
            .where(
              (t) =>
                  t.categoryId == event.categoryId &&
                  t.type == TransactionType.expense,
            )
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        await _repository.updateBudgetSpentAmount(budget.id, spent);
      }

      // Reload so the UI reflects the updated spentAmount values.
      add(LoadBudgetsEvent());
    } catch (e) {
      // Sync failures are silent — they should not disrupt the transaction flow.
      // Budget amounts will correct themselves on next manual refresh.
    }
  }

  /// Convenience handler: syncs spentAmount for every active budget.
  /// Called once on screen open so progress bars always show real data.
  Future<void> _onSyncAllBudgetsSpentAmount(
    SyncAllBudgetsSpentAmountEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final budgets = await _repository.getAllBudgets();
      final active = budgets.where((b) => b.isActive).toList();

      if (active.isEmpty) return;

      for (final budget in active) {
        final endDate = budget.endDate ?? DateTime.now();
        final transactions = await _transactionRepository.fetchByDateRange(
          from: budget.startDate,
          to: endDate,
        );

        final spent = transactions
            .where(
              (t) =>
                  t.categoryId == budget.categoryId &&
                  t.type == TransactionType.expense,
            )
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        await _repository.updateBudgetSpentAmount(budget.id, spent);
      }

      // Reload so the UI reflects all updated spentAmount values.
      add(LoadBudgetsEvent());
    } catch (_) {
      // Silent failure — progress bars will refresh on next pull-to-refresh.
    }
  }
}
