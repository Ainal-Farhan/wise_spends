import 'package:equatable/equatable.dart';

/// Linked Account Summary Entity - summary of an account linked to a plan
class LinkedAccountSummaryEntity extends Equatable {
  final String id;
  final String planId;
  final String accountId;
  final String accountName;
  final String accountType;
  final double accountBalance;
  final double? allocatedPercentage;
  final double allocatedAmount;
  final DateTime linkedAt;

  const LinkedAccountSummaryEntity({
    required this.id,
    required this.planId,
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.accountBalance,
    this.allocatedPercentage,
    required this.allocatedAmount,
    required this.linkedAt,
  });

  @override
  List<Object?> get props => [
        id,
        planId,
        accountId,
        accountName,
        accountType,
        accountBalance,
        allocatedPercentage,
        allocatedAmount,
        linkedAt,
      ];

  LinkedAccountSummaryEntity copyWith({
    String? id,
    String? planId,
    String? accountId,
    String? accountName,
    String? accountType,
    double? accountBalance,
    double? allocatedPercentage,
    double? allocatedAmount,
    DateTime? linkedAt,
  }) {
    return LinkedAccountSummaryEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      accountBalance: accountBalance ?? this.accountBalance,
      allocatedPercentage: allocatedPercentage ?? this.allocatedPercentage,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      linkedAt: linkedAt ?? this.linkedAt,
    );
  }
}

/// Budget Plan Linked Account Entity
class BudgetPlanLinkedAccountEntity extends Equatable {
  final String id;
  final String planId;
  final String accountId;
  final double? allocatedPercentage;
  final DateTime linkedAt;

  const BudgetPlanLinkedAccountEntity({
    required this.id,
    required this.planId,
    required this.accountId,
    this.allocatedPercentage,
    required this.linkedAt,
  });

  @override
  List<Object?> get props => [
        id,
        planId,
        accountId,
        allocatedPercentage,
        linkedAt,
      ];

  BudgetPlanLinkedAccountEntity copyWith({
    String? id,
    String? planId,
    String? accountId,
    double? allocatedPercentage,
    DateTime? linkedAt,
  }) {
    return BudgetPlanLinkedAccountEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      accountId: accountId ?? this.accountId,
      allocatedPercentage: allocatedPercentage ?? this.allocatedPercentage,
      linkedAt: linkedAt ?? this.linkedAt,
    );
  }
}
