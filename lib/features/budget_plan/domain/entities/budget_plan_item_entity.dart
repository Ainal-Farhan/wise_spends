import 'package:equatable/equatable.dart';
import 'package:wise_spends/core/config/localization_service.dart';

/// Budget Plan Item Entity — represents a line item in a budget plan.
///
/// ## Field semantics
///
/// | Field         | Meaning                                                         |
/// |---------------|-----------------------------------------------------------------|
/// | totalCost     | Full agreed price of the item                                   |
/// | depositPaid   | Amount paid as deposit (a partial upfront commitment)           |
/// | amountPaid    | Amount paid toward the remaining balance, **excluding deposit** |
///
/// So the total money handed over is `depositPaid + amountPaid`, and the
/// outstanding balance is `totalCost - depositPaid - amountPaid`.
///
/// ## Example
///   totalCost  = 1000
///   depositPaid = 500   ← deposit settled
///   amountPaid  = 250   ← partial payment on remaining 500
///   → totalPaid    = 750
///   → outstanding  = 250
///   → progress     = 75%
class BudgetPlanItemEntity extends Equatable {
  final String id;
  final String planId;
  final double sortOrder;

  /// User-editable display number (e.g. "1", "28").
  /// Separate from [sortOrder] which is used only for fractional ordering.
  final String bil;

  final String name;
  final double totalCost;

  /// Amount paid as deposit (upfront commitment).
  final double depositPaid;

  /// Amount paid toward the remaining balance, **excluding** [depositPaid].
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
    required this.bil,
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

  // ---------------------------------------------------------------------------
  // Core computed values
  // ---------------------------------------------------------------------------

  /// Total money handed over: deposit + non-deposit payment.
  double get totalPaid => depositPaid + amountPaid;

  /// Remaining balance still owed: totalCost − depositPaid − amountPaid.
  double get outstanding =>
      (totalCost - depositPaid - amountPaid).clamp(0.0, double.infinity);

  /// True when [outstanding] == 0 and totalCost > 0.
  bool get isFullyPaid => totalCost > 0 && outstanding <= 0;

  /// Payment progress as a fraction (0.0–1.0), based on [totalPaid].
  double get paymentProgress {
    if (totalCost <= 0) return 0.0;
    return (totalPaid / totalCost).clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------------
  // Deposit helpers
  // ---------------------------------------------------------------------------

  /// True when a deposit has been recorded.
  bool get hasDeposit => depositPaid > 0;

  /// The balance still owed after the deposit (before any [amountPaid]).
  double get remainingAfterDeposit =>
      (totalCost - depositPaid).clamp(0.0, double.infinity);

  /// True when deposit alone covers the full cost.
  bool get depositCoversFullCost => depositPaid >= totalCost && totalCost > 0;

  // ---------------------------------------------------------------------------
  // Status labels
  // ---------------------------------------------------------------------------

  /// Localized payment status label — reflects both deposit and payment state.
  String get paymentStatusLabel {
    if (isFullyPaid) return 'budget_plans.status_fully_paid'.tr;
    if (amountPaid > 0 && outstanding > 0) {
      return 'budget_plans.status_partially_paid'.tr;
    }
    if (hasDeposit && amountPaid == 0) {
      return 'budget_plans.status_deposit_only'.tr;
    }
    return 'budget_plans.status_not_paid'.tr;
  }

  /// Localized deposit status label.
  String get depositStatusLabel {
    if (!hasDeposit) return 'budget_plans.status_no_deposit'.tr;
    if (depositCoversFullCost) return 'budget_plans.status_deposit_full'.tr;
    return 'budget_plans.status_deposit_partial'.tr;
  }

  // ---------------------------------------------------------------------------
  // Equatable / copyWith
  // ---------------------------------------------------------------------------

  @override
  List<Object?> get props => [
    id,
    planId,
    sortOrder,
    bil,
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
    String? bil,
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
      bil: bil ?? this.bil,
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
