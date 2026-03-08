import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';

/// Budget BLoC states
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// INITIAL & LOADING STATES
// ============================================================================

/// Initial state — before any data has been requested
class BudgetInitial extends BudgetState {}

/// Loading state — data fetch is in progress
class BudgetLoading extends BudgetState {}

// ============================================================================
// SUCCESS STATES
// ============================================================================

/// Budgets loaded successfully.
///
/// [budgets] is the (optionally filtered) list currently shown in the UI.
/// [allBudgets] is the full unfiltered list kept for client-side filtering
/// without a round-trip to the database.
///
/// NOTE: props intentionally includes a [_timestamp] so that re-filtering to
/// the same period always produces a distinct state and is never swallowed by
/// Bloc's Equatable deduplication.
class BudgetsLoaded extends BudgetState {
  /// The list currently visible in the UI (may be filtered).
  final List<BudgetEntity> budgets;

  /// Full unfiltered list — kept so we can re-filter without a DB call.
  final List<BudgetEntity> allBudgets;

  /// Number of active budgets in [allBudgets].
  final int activeCount;

  /// Number of budgets that have not exceeded their limit.
  final int onTrackCount;

  /// Currently active period filter, or null when showing all.
  final BudgetPeriod? filterPeriod;

  /// Maps categoryId → category display name for the card subtitle.
  /// Populated when budgets are loaded; empty map if lookup fails.
  final Map<String, String> categoryNames;

  /// Monotonic timestamp so every emission is treated as distinct.
  final int _timestamp;

  BudgetsLoaded({
    required this.budgets,
    List<BudgetEntity>? allBudgets,
    this.activeCount = 0,
    this.onTrackCount = 0,
    this.filterPeriod,
    this.categoryNames = const {},
  }) : allBudgets = allBudgets ?? budgets,
       _timestamp = DateTime.now().microsecondsSinceEpoch;

  /// Convenience copy-with used by filter events to avoid full DB reload.
  BudgetsLoaded copyWith({
    List<BudgetEntity>? budgets,
    List<BudgetEntity>? allBudgets,
    int? activeCount,
    int? onTrackCount,
    BudgetPeriod? filterPeriod,
    Map<String, String>? categoryNames,
    bool clearFilter = false,
  }) {
    return BudgetsLoaded(
      budgets: budgets ?? this.budgets,
      allBudgets: allBudgets ?? this.allBudgets,
      activeCount: activeCount ?? this.activeCount,
      onTrackCount: onTrackCount ?? this.onTrackCount,
      filterPeriod: clearFilter ? null : (filterPeriod ?? this.filterPeriod),
      categoryNames: categoryNames ?? this.categoryNames,
    );
  }

  @override
  List<Object?> get props => [
    budgets,
    allBudgets,
    activeCount,
    onTrackCount,
    filterPeriod,
    categoryNames,
    _timestamp,
  ];
}

/// A single budget was loaded (e.g. for a detail screen).
class BudgetLoaded extends BudgetState {
  final BudgetEntity budget;

  const BudgetLoaded(this.budget);

  @override
  List<Object> get props => [budget];
}

/// Budget created successfully.
class BudgetCreated extends BudgetState {
  final BudgetEntity budget;

  const BudgetCreated(this.budget);

  @override
  List<Object> get props => [budget];
}

/// Budget updated successfully.
class BudgetUpdated extends BudgetState {
  final BudgetEntity budget;

  const BudgetUpdated(this.budget);

  @override
  List<Object> get props => [budget];
}

/// Budget(s) deleted successfully.
///
/// [budgetId] is `'multiple'` when more than one budget was deleted at once.
class BudgetDeleted extends BudgetState {
  final String budgetId;

  const BudgetDeleted(this.budgetId);

  @override
  List<Object> get props => [budgetId];
}

// ============================================================================
// ERROR & EMPTY STATES
// ============================================================================

/// An error occurred during a budget operation.
class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object> get props => [message];
}

/// No budgets exist (or none matched the current filter).
class BudgetEmpty extends BudgetState {
  final String message;

  const BudgetEmpty([this.message = 'No budgets found']);

  @override
  List<Object> get props => [message];
}
