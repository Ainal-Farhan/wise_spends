import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';
import 'package:wise_spends/domain/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

/// Budget BLoC - manages budget state and business logic
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final IBudgetRepository _repository;

  BudgetBloc(this._repository) : super(BudgetInitial()) {
    on<LoadBudgetsEvent>(_onLoadBudgets);
    on<LoadActiveBudgetsEvent>(_onLoadActiveBudgets);
    on<LoadBudgetsByCategoryEvent>(_onLoadBudgetsByCategory);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<DeleteMultipleBudgetsEvent>(_onDeleteMultipleBudgets);
    on<RefreshBudgetsEvent>(_onRefreshBudgets);
    on<ReloadBudgetsEvent>(_onReloadBudgets);
  }

  /// Load all budgets
  Future<void> _onLoadBudgets(
    LoadBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getAllBudgets();
      
      if (budgets.isEmpty) {
        emit(const BudgetEmpty('You haven\'t set any budgets yet'));
      } else {
        // Calculate how many budgets are on track
        final onTrackCount = budgets.where((budget) {
          return !budget.isExceeded;
        }).length;

        emit(BudgetsLoaded(
          budgets: budgets,
          activeCount: budgets.where((b) => b.isActive).length,
          onTrackCount: onTrackCount,
        ));
      }
    } catch (e) {
      emit(BudgetError('Failed to load budgets: ${e.toString()}'));
    }
  }

  /// Load active budgets only
  Future<void> _onLoadActiveBudgets(
    LoadActiveBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getActiveBudgets();
      
      if (budgets.isEmpty) {
        emit(const BudgetEmpty('No active budgets'));
      } else {
        emit(BudgetsLoaded(budgets: budgets));
      }
    } catch (e) {
      emit(BudgetError('Failed to load active budgets: ${e.toString()}'));
    }
  }

  /// Load budgets by category
  Future<void> _onLoadBudgetsByCategory(
    LoadBudgetsByCategoryEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getBudgetsByCategory(event.categoryId);
      emit(BudgetsLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError('Failed to load budgets: ${e.toString()}'));
    }
  }

  /// Create a new budget
  Future<void> _onCreateBudget(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budget = BudgetEntity(
        id: const Uuid().v4(),
        name: event.name,
        categoryId: event.categoryId,
        limitAmount: event.amount,
        period: _getPeriodFromDates(event.startDate, event.endDate),
        startDate: event.startDate,
        endDate: event.endDate,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.createBudget(budget);
      emit(BudgetCreated(budget));
      
      // Reload budgets after creation
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to create budget: ${e.toString()}'));
    }
  }

  /// Update an existing budget
  Future<void> _onUpdateBudget(
    UpdateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final currentBudget = await _repository.getBudgetById(event.budgetId);
      if (currentBudget == null) {
        emit(const BudgetError('Budget not found'));
        return;
      }
      
      final updatedBudget = currentBudget.copyWith(
        name: event.name ?? currentBudget.name,
        limitAmount: event.amount ?? currentBudget.limitAmount,
        categoryId: event.categoryId ?? currentBudget.categoryId,
        startDate: event.startDate ?? currentBudget.startDate,
        endDate: event.endDate ?? currentBudget.endDate,
        updatedAt: DateTime.now(),
      );
      
      await _repository.updateBudget(updatedBudget);
      emit(BudgetUpdated(updatedBudget));
      
      // Reload budgets after update
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to update budget: ${e.toString()}'));
    }
  }

  /// Delete a budget
  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _repository.deleteBudget(event.budgetId);
      emit(BudgetDeleted(event.budgetId));
      
      // Reload budgets after deletion
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to delete budget: ${e.toString()}'));
    }
  }

  /// Delete multiple budgets
  Future<void> _onDeleteMultipleBudgets(
    DeleteMultipleBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      for (final id in event.budgetIds) {
        await _repository.deleteBudget(id);
      }
      emit(const BudgetDeleted('multiple'));
      
      // Reload budgets after batch deletion
      add(LoadBudgetsEvent());
    } catch (e) {
      emit(BudgetError('Failed to delete budgets: ${e.toString()}'));
    }
  }

  /// Refresh budgets
  Future<void> _onRefreshBudgets(
    RefreshBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final budgets = await _repository.getAllBudgets();
      emit(BudgetsLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError('Failed to refresh budgets: ${e.toString()}'));
    }
  }

  /// Reload budgets
  Future<void> _onReloadBudgets(
    ReloadBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    add(LoadBudgetsEvent());
  }

  /// Helper method to determine budget period from dates
  BudgetPeriod _getPeriodFromDates(DateTime startDate, DateTime? endDate) {
    if (endDate == null) return BudgetPeriod.monthly;
    
    final difference = endDate.difference(startDate).inDays;
    
    if (difference <= 1) return BudgetPeriod.daily;
    if (difference <= 7) return BudgetPeriod.weekly;
    if (difference <= 31) return BudgetPeriod.monthly;
    return BudgetPeriod.yearly;
  }
}
