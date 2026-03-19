import 'package:equatable/equatable.dart';

/// Budget Plan Deposit Entity - money saved toward a goal
class BudgetPlanDepositEntity extends Equatable {
  final String id;
  final String planId;
  final double amount;
  final String? note;
  final String source; // manual, linked_account, salary, bonus, other
  final DateTime depositDate;
  final String? linkedAccountId;
  final DateTime createdAt;

  const BudgetPlanDepositEntity({
    required this.id,
    required this.planId,
    required this.amount,
    this.note,
    this.source = 'manual',
    required this.depositDate,
    this.linkedAccountId,
    required this.createdAt,
  });

  /// Get source display name
  String get sourceDisplayName {
    switch (source.toLowerCase()) {
      case 'manual':
        return 'Manual';
      case 'linked_account':
        return 'Linked Account';
      case 'salary':
        return 'Salary';
      case 'bonus':
        return 'Bonus';
      case 'other':
        return 'Other';
      default:
        return source;
    }
  }

  @override
  List<Object?> get props => [
    id,
    planId,
    amount,
    note,
    source,
    depositDate,
    linkedAccountId,
    createdAt,
  ];

  BudgetPlanDepositEntity copyWith({
    String? id,
    String? planId,
    double? amount,
    String? note,
    String? source,
    DateTime? depositDate,
    String? linkedAccountId,
    DateTime? createdAt,
  }) {
    return BudgetPlanDepositEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      source: source ?? this.source,
      depositDate: depositDate ?? this.depositDate,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
