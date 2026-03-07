import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

enum TransactionType {
  income(
    label: 'Income',
    icon: Icons.arrow_downward_rounded,
    color: AppColors.income,
  ),
  expense(
    label: 'Expense',
    icon: Icons.arrow_upward_rounded,
    color: AppColors.expense,
  ),
  transfer(
    label: 'Transfer',
    icon: Icons.swap_horiz_rounded,
    color: AppColors.transfer,
  ),
  commitment(
    label: 'Commitment',
    icon: Icons.event_repeat_rounded,
    color: AppColors.commitment,
  );

  const TransactionType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
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
