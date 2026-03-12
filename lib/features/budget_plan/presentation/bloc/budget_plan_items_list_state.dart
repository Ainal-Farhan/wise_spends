import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_item_entity.dart';

/// Budget Plan Items List BLoC States
/// 
/// Follows the standard state pattern from BudgetPlanListState
abstract class BudgetPlanItemsListState extends Equatable {
  const BudgetPlanItemsListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BudgetPlanItemsListInitial extends BudgetPlanItemsListState {}

/// Loading state
class BudgetPlanItemsListLoading extends BudgetPlanItemsListState {}

/// Loaded state with items
class BudgetPlanItemsListLoaded extends BudgetPlanItemsListState {
  final List<BudgetPlanItemEntity> items;
  final List<BudgetPlanItemEntity> filteredItems;
  final String? filterPaymentStatus;
  final String? filterTag;
  final BudgetPlanItemsSummary summary;

  const BudgetPlanItemsListLoaded({
    required this.items,
    required this.filteredItems,
    this.filterPaymentStatus,
    this.filterTag,
    required this.summary,
  });

  @override
  List<Object?> get props => [
    items,
    filteredItems,
    filterPaymentStatus,
    filterTag,
    summary,
  ];

  BudgetPlanItemsListLoaded copyWith({
    List<BudgetPlanItemEntity>? items,
    List<BudgetPlanItemEntity>? filteredItems,
    String? filterPaymentStatus,
    String? filterTag,
    BudgetPlanItemsSummary? summary,
  }) {
    return BudgetPlanItemsListLoaded(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      filterPaymentStatus: filterPaymentStatus ?? this.filterPaymentStatus,
      filterTag: filterTag ?? this.filterTag,
      summary: summary ?? this.summary,
    );
  }
}

/// Error state
class BudgetPlanItemsListError extends BudgetPlanItemsListState {
  final String message;

  const BudgetPlanItemsListError(this.message);

  @override
  List<Object> get props => [message];
}

/// Empty state (no items for this plan)
class BudgetPlanItemsListEmpty extends BudgetPlanItemsListState {
  final String message;

  const BudgetPlanItemsListEmpty([this.message = 'No items yet']);

  @override
  List<Object> get props => [message];
}

/// Item created success
class BudgetPlanItemCreated extends BudgetPlanItemsListState {
  final BudgetPlanItemEntity item;

  const BudgetPlanItemCreated(this.item);

  @override
  List<Object> get props => [item];
}

/// Item updated success
class BudgetPlanItemUpdated extends BudgetPlanItemsListState {
  final BudgetPlanItemEntity item;

  const BudgetPlanItemUpdated(this.item);

  @override
  List<Object> get props => [item];
}

/// Item deleted success
class BudgetPlanItemDeleted extends BudgetPlanItemsListState {
  final String itemId;

  const BudgetPlanItemDeleted(this.itemId);

  @override
  List<Object> get props => [itemId];
}

/// Error during delete operation - preserves list state
class BudgetPlanItemsListDeleteError extends BudgetPlanItemsListState {
  final String message;
  final BudgetPlanItemsListLoaded? previousState;

  const BudgetPlanItemsListDeleteError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

/// Error during refresh operation - preserves list state
class BudgetPlanItemsListRefreshError extends BudgetPlanItemsListState {
  final String message;
  final BudgetPlanItemsListLoaded previousState;

  const BudgetPlanItemsListRefreshError({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

/// Summary of budget plan items
class BudgetPlanItemsSummary extends Equatable {
  final int totalItems;
  final int fullyPaidItems;
  final int depositPaidItems;
  final int outstandingItems;
  final double totalCost;
  final double totalDepositPaid;
  final double totalAmountPaid;
  final double totalOutstanding;

  const BudgetPlanItemsSummary({
    required this.totalItems,
    required this.fullyPaidItems,
    required this.depositPaidItems,
    required this.outstandingItems,
    required this.totalCost,
    required this.totalDepositPaid,
    required this.totalAmountPaid,
    required this.totalOutstanding,
  });

  /// Create from list of items
  factory BudgetPlanItemsSummary.fromItems(List<BudgetPlanItemEntity> items) {
    final totalCost = items.fold<double>(0, (sum, item) => sum + item.totalCost);
    final totalDepositPaid = items.fold<double>(
      0,
      (sum, item) => sum + item.depositPaid,
    );
    final totalAmountPaid = items.fold<double>(
      0,
      (sum, item) => sum + item.amountPaid,
    );
    final totalOutstanding = items.fold<double>(
      0,
      (sum, item) => sum + item.outstanding,
    );

    return BudgetPlanItemsSummary(
      totalItems: items.length,
      fullyPaidItems: items.where((i) => i.isFullyPaid).length,
      depositPaidItems: items.where(
        (i) => i.depositPaid > 0 && !i.isFullyPaid,
      ).length,
      outstandingItems: items.where((i) => !i.isFullyPaid && i.depositPaid == 0).length,
      totalCost: totalCost,
      totalDepositPaid: totalDepositPaid,
      totalAmountPaid: totalAmountPaid,
      totalOutstanding: totalOutstanding,
    );
  }

  @override
  List<Object?> get props => [
    totalItems,
    fullyPaidItems,
    depositPaidItems,
    outstandingItems,
    totalCost,
    totalDepositPaid,
    totalAmountPaid,
    totalOutstanding,
  ];
}
