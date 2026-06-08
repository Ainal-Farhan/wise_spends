import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_revoke_entity.dart';

enum TransactionType {
  income,
  expense,
  transfer,
  commitment,
  budgetPlanDeposit,
  budgetPlanExpense,
  loanDisbursement,
  loanRepayment,
  lendingDisbursement,
  lendingRepayment;

  /// Get localized label for transaction type
  String get label {
    switch (this) {
      case income:
        return 'transaction.type.income'.tr;
      case expense:
        return 'transaction.type.expense'.tr;
      case transfer:
        return 'transaction.type.transfer'.tr;
      case commitment:
        return 'transaction.type.commitment'.tr;
      case budgetPlanDeposit:
        return 'transaction.type.budget_plan_deposit'.tr;
      case budgetPlanExpense:
        return 'transaction.type.budget_plan_expense'.tr;
      case loanDisbursement:
        return 'transaction.type.loan_disbursement'.tr;
      case loanRepayment:
        return 'transaction.type.loan_repayment'.tr;
      case lendingDisbursement:
        return 'transaction.type.lending_disbursement'.tr;
      case lendingRepayment:
        return 'transaction.type.lending_repayment'.tr;
    }
  }

  /// Get icon for transaction type
  IconData get icon {
    switch (this) {
      case income:
        return Icons.arrow_downward_rounded;
      case expense:
        return Icons.arrow_upward_rounded;
      case transfer:
        return Icons.swap_horiz_rounded;
      case commitment:
        return Icons.event_repeat_rounded;
      case budgetPlanDeposit:
        return Icons.add_card_rounded;
      case budgetPlanExpense:
        return Icons.payment_rounded;
      case loanDisbursement:
        return Icons.handshake_outlined;
      case loanRepayment:
        return Icons.payment_rounded;
      case lendingDisbursement:
        return Icons.volunteer_activism_outlined;
      case lendingRepayment:
        return Icons.savings_outlined;
    }
  }

  /// Get color for transaction type
  Color getBackgroundColor(BuildContext context) {
    switch (this) {
      case income:
        return Theme.of(context).colorScheme.primary;
      case expense:
        return Theme.of(context).colorScheme.secondary;
      case transfer:
        return Theme.of(context).colorScheme.tertiary;
      case commitment:
        return Theme.of(context).colorScheme.tertiary;
      case budgetPlanDeposit:
        return Theme.of(context).colorScheme.primary;
      case budgetPlanExpense:
        return Theme.of(context).colorScheme.primary;
      case loanDisbursement:
        return Theme.of(context).colorScheme.secondary;
      case loanRepayment:
        return Theme.of(context).colorScheme.primary;
      case lendingDisbursement:
        return Theme.of(context).colorScheme.secondary;
      case lendingRepayment:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;

  // -- Account links ---------------------------------------------------------
  final String savingId;
  final String? destinationSavingId;

  // -- Relations -------------------------------------------------------------
  final String? categoryId;
  final CategoryEntity? category;
  final String? commitmentTaskId;
  final String? payeeId;
  final String? loanId;
  final String? lendingId;

  // -- Metadata --------------------------------------------------------------
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TransactionRevokeEntity? revoke;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.savingId,
    this.destinationSavingId,
    this.categoryId,
    this.category,
    this.commitmentTaskId,
    this.payeeId,
    this.loanId,
    this.lendingId,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.revoke,
  });

  /// Alias — call sites that used sourceAccountId still compile.
  String get sourceAccountId => savingId;

  /// Check if this transaction has been revoked.
  bool get isRevoked => revoke != null;

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    type,
    savingId,
    destinationSavingId,
    categoryId,
    category,
    commitmentTaskId,
    payeeId,
    loanId,
    lendingId,
    date,
    note,
    createdAt,
    updatedAt,
    revoke,
  ];

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? savingId,
    String? destinationSavingId,
    String? categoryId,
    CategoryEntity? category,
    String? commitmentTaskId,
    String? payeeId,
    String? loanId,
    String? lendingId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransactionRevokeEntity? revoke,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      savingId: savingId ?? this.savingId,
      destinationSavingId: destinationSavingId ?? this.destinationSavingId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      commitmentTaskId: commitmentTaskId ?? this.commitmentTaskId,
      payeeId: payeeId ?? this.payeeId,
      loanId: loanId ?? this.loanId,
      lendingId: lendingId ?? this.lendingId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      revoke: revoke ?? this.revoke,
    );
  }
}
