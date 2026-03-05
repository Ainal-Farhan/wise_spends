import 'package:equatable/equatable.dart';

/// Budget Plan Transaction Entity - money spent from a goal
class BudgetPlanTransactionEntity extends Equatable {
  final int? id;
  final String uuid;
  final int planId;
  final int? transactionId;
  final double amount;
  final String? description;
  final String? vendor;
  final String? receiptImagePath;
  final DateTime transactionDate;
  final DateTime createdAt;

  const BudgetPlanTransactionEntity({
    this.id,
    required this.uuid,
    required this.planId,
    this.transactionId,
    required this.amount,
    this.description,
    this.vendor,
    this.receiptImagePath,
    required this.transactionDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        planId,
        transactionId,
        amount,
        description,
        vendor,
        receiptImagePath,
        transactionDate,
        createdAt,
      ];

  BudgetPlanTransactionEntity copyWith({
    int? id,
    String? uuid,
    int? planId,
    int? transactionId,
    double? amount,
    String? description,
    String? vendor,
    String? receiptImagePath,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return BudgetPlanTransactionEntity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
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
