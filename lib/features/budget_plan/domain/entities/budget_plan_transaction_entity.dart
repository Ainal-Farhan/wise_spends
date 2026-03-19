import 'package:equatable/equatable.dart';

/// Budget Plan Transaction Entity - money spent from a goal
class BudgetPlanTransactionEntity extends Equatable {
  final String id;
  final String planId;
  final String? transactionId;
  final double amount;
  final String? description;
  final String? vendor;
  final String? receiptImagePath;
  final String? linkedAccountId;
  final DateTime transactionDate;
  final DateTime createdAt;

  const BudgetPlanTransactionEntity({
    required this.id,
    required this.planId,
    this.transactionId,
    required this.amount,
    this.description,
    this.vendor,
    this.receiptImagePath,
    this.linkedAccountId,
    required this.transactionDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    planId,
    transactionId,
    amount,
    description,
    vendor,
    receiptImagePath,
    linkedAccountId,
    transactionDate,
    createdAt,
  ];

  BudgetPlanTransactionEntity copyWith({
    String? id,
    String? planId,
    String? transactionId,
    double? amount,
    String? description,
    String? vendor,
    String? receiptImagePath,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return BudgetPlanTransactionEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      vendor: vendor ?? this.vendor,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
