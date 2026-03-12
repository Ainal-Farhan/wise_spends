import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

enum TransactionType {
  income,
  expense,
  transfer,
  commitment,
  budgetPlanDeposit,
  budgetPlanExpense;

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
    }
  }

  /// Get color for transaction type
  Color get color {
    switch (this) {
      case income:
        return AppColors.income;
      case expense:
        return AppColors.expense;
      case transfer:
        return AppColors.transfer;
      case commitment:
        return AppColors.commitment;
      case budgetPlanDeposit:
        return AppColors.budgetPlan;
      case budgetPlanExpense:
        return AppColors.budgetPlan;
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
  final String? commitmentTaskId;
  final String? payeeId;

  // -- Metadata --------------------------------------------------------------
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.savingId,
    this.destinationSavingId,
    this.categoryId,
    this.commitmentTaskId,
    this.payeeId,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Alias — call sites that used sourceAccountId still compile.
  String get sourceAccountId => savingId;

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    type,
    savingId,
    destinationSavingId,
    categoryId,
    commitmentTaskId,
    payeeId,
    date,
    note,
    createdAt,
    updatedAt,
  ];

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? savingId,
    String? destinationSavingId,
    String? categoryId,
    String? commitmentTaskId,
    String? payeeId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      savingId: savingId ?? this.savingId,
      destinationSavingId: destinationSavingId ?? this.destinationSavingId,
      categoryId: categoryId ?? this.categoryId,
      commitmentTaskId: commitmentTaskId ?? this.commitmentTaskId,
      payeeId: payeeId ?? this.payeeId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
