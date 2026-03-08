import 'package:equatable/equatable.dart';

/// Budget Plan Item Entity - represents a line item in a budget plan
/// 
/// This entity tracks individual budget items (e.g., "Pelamin", "Makeup", "Hantaran")
/// with cost breakdown: total cost, deposit paid, amount paid.
/// 
/// The `outstanding` amount is computed as `totalCost - amountPaid`.
class BudgetPlanItemEntity extends Equatable {
  final String id;
  final String planId;
  final double sortOrder;
  final String name;
  final double totalCost;
  final double depositPaid;
  final double amountPaid;
  final String? notes;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  const BudgetPlanItemEntity({
    required this.id,
    required this.planId,
    required this.sortOrder,
    required this.name,
    required this.totalCost,
    this.depositPaid = 0.0,
    this.amountPaid = 0.0,
    this.notes,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  /// Computed: Outstanding amount (what's still owed)
  /// This is a getter to ensure it's always accurate and never out of sync.
  double get outstanding => totalCost - amountPaid;

  /// Computed: Whether the item is fully paid
  bool get isFullyPaid => outstanding <= 0;

  /// Computed: Payment progress percentage (0.0 to 1.0)
  double get paymentProgress {
    if (totalCost <= 0) return 0.0;
    return (amountPaid / totalCost).clamp(0.0, 1.0);
  }

  /// Computed: Payment status label
  String get paymentStatusLabel {
    if (isFullyPaid) return 'Fully Paid';
    if (depositPaid > 0 && amountPaid < totalCost) return 'Deposit Paid';
    if (amountPaid == 0) return 'Not Paid';
    return 'Partially Paid';
  }

  @override
  List<Object?> get props => [
    id,
    planId,
    sortOrder,
    name,
    totalCost,
    depositPaid,
    amountPaid,
    notes,
    isCompleted,
    dueDate,
    createdAt,
    updatedAt,
    tags,
  ];

  BudgetPlanItemEntity copyWith({
    String? id,
    String? planId,
    double? sortOrder,
    String? name,
    double? totalCost,
    double? depositPaid,
    double? amountPaid,
    String? notes,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return BudgetPlanItemEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      totalCost: totalCost ?? this.totalCost,
      depositPaid: depositPaid ?? this.depositPaid,
      amountPaid: amountPaid ?? this.amountPaid,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}
