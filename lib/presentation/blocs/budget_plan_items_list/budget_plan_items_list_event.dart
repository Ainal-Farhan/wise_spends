import 'package:equatable/equatable.dart';

/// Budget Plan Items List BLoC Events
///
/// Follows the standard event pattern from BudgetPlanListEvent
abstract class BudgetPlanItemsListEvent extends Equatable {
  const BudgetPlanItemsListEvent();

  @override
  List<Object?> get props => [];
}

/// Load all items for a budget plan
class LoadBudgetPlanItems extends BudgetPlanItemsListEvent {
  final String planId;

  const LoadBudgetPlanItems(this.planId);

  @override
  List<Object> get props => [planId];
}

/// Refresh items list (pull-to-refresh)
class RefreshBudgetPlanItems extends BudgetPlanItemsListEvent {
  final String planId;

  const RefreshBudgetPlanItems(this.planId);

  @override
  List<Object> get props => [planId];
}

/// Filter items by payment status and/or tag
class FilterBudgetPlanItems extends BudgetPlanItemsListEvent {
  /// null = show all; 'deposit' | 'paid' | 'outstanding'
  final String? paymentStatus;

  /// null = show all tags
  final String? tag;

  const FilterBudgetPlanItems({this.paymentStatus, this.tag});

  @override
  List<Object?> get props => [paymentStatus, tag];
}

/// Create a new budget plan item
class CreateBudgetPlanItem extends BudgetPlanItemsListEvent {
  final String planId;
  final String bil;
  final String name;
  final double totalCost;
  final double depositPaid;
  final double amountPaid;
  final String? notes;
  final DateTime? dueDate;
  final List<String> tags;

  const CreateBudgetPlanItem({
    required this.planId,
    required this.bil,
    required this.name,
    required this.totalCost,
    this.depositPaid = 0.0,
    this.amountPaid = 0.0,
    this.notes,
    this.dueDate,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
    planId,
    bil,
    name,
    totalCost,
    depositPaid,
    amountPaid,
    notes,
    dueDate,
    tags,
  ];
}

/// Update an existing budget plan item
///
/// All fields are nullable — only non-null fields are updated.
/// To explicitly CLEAR a nullable field (e.g. notes), use the
/// [clearNotes] / [clearDueDate] flags instead of passing null,
/// since null means "leave unchanged" here.
class UpdateBudgetPlanItem extends BudgetPlanItemsListEvent {
  final String itemId;
  final String? bil;
  final String? name;
  final double? totalCost;
  final double? depositPaid;
  final double? amountPaid;
  final String? notes;
  final bool clearNotes; // true = set notes to null in DB
  final bool? isCompleted;
  final DateTime? dueDate;
  final bool clearDueDate; // true = set dueDate to null in DB
  final List<String>? tags;

  const UpdateBudgetPlanItem({
    required this.itemId,
    this.bil,
    this.name,
    this.totalCost,
    this.depositPaid,
    this.amountPaid,
    this.notes,
    this.clearNotes = false,
    this.isCompleted,
    this.dueDate,
    this.clearDueDate = false,
    this.tags,
  });

  @override
  List<Object?> get props => [
    itemId,
    bil,
    name,
    totalCost,
    depositPaid,
    amountPaid,
    notes,
    clearNotes,
    isCompleted,
    dueDate,
    clearDueDate,
    tags,
  ];
}

/// Delete a budget plan item
class DeleteBudgetPlanItem extends BudgetPlanItemsListEvent {
  final String itemId;
  final String planId;

  const DeleteBudgetPlanItem(this.itemId, this.planId);

  @override
  List<Object> get props => [itemId, planId];
}

/// Reorder items using fractional indexing
class ReorderBudgetPlanItems extends BudgetPlanItemsListEvent {
  final String itemId;
  final double newSortOrder;

  const ReorderBudgetPlanItems(this.itemId, this.newSortOrder);

  @override
  List<Object> get props => [itemId, newSortOrder];
}

/// Clear all items state (when navigating away from a plan)
class ClearBudgetPlanItems extends BudgetPlanItemsListEvent {
  const ClearBudgetPlanItems();
}
