import 'package:equatable/equatable.dart';

/// Parameters for creating a budget plan item
class CreateBudgetPlanItemParams extends Equatable {
  final String planId;
  final String name;
  final double totalCost;
  final double depositPaid;
  final double amountPaid;
  final String? notes;
  final DateTime? dueDate;
  final List<String> tags;

  const CreateBudgetPlanItemParams({
    required this.planId,
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
    name,
    totalCost,
    depositPaid,
    amountPaid,
    notes,
    dueDate,
    tags,
  ];
}

/// Parameters for updating a budget plan item
class UpdateBudgetPlanItemParams extends Equatable {
  final String? name;
  final double? totalCost;
  final double? depositPaid;
  final double? amountPaid;
  final String? notes;
  final bool? isCompleted;
  final DateTime? dueDate;
  final List<String>? tags;

  const UpdateBudgetPlanItemParams({
    this.name,
    this.totalCost,
    this.depositPaid,
    this.amountPaid,
    this.notes,
    this.isCompleted,
    this.dueDate,
    this.tags,
  });

  @override
  List<Object?> get props => [
    name,
    totalCost,
    depositPaid,
    amountPaid,
    notes,
    isCompleted,
    dueDate,
    tags,
  ];
}

/// Parameters for reordering budget plan items
/// Uses fractional indexing to insert between items without renumbering
class ReorderBudgetPlanItemParams extends Equatable {
  final String itemId;
  final double newSortOrder;

  const ReorderBudgetPlanItemParams({
    required this.itemId,
    required this.newSortOrder,
  });

  @override
  List<Object?> get props => [itemId, newSortOrder];
}
