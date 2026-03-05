import 'package:equatable/equatable.dart';

/// Transaction type enum
enum TransactionType {
  income,
  expense,
  transfer,
}

/// Main transaction entity - pure data class
class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final DateTime date;
  final String? note;
  final String? sourceAccountId;
  final String? destinationAccountId;
  final String? receiptImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    required this.date,
    this.note,
    this.sourceAccountId,
    this.destinationAccountId,
    this.receiptImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        type,
        categoryId,
        categoryName,
        categoryIcon,
        date,
        note,
        sourceAccountId,
        destinationAccountId,
        receiptImagePath,
        createdAt,
        updatedAt,
      ];

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    DateTime? date,
    String? note,
    String? sourceAccountId,
    String? destinationAccountId,
    String? receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      date: date ?? this.date,
      note: note ?? this.note,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId:
          destinationAccountId ?? this.destinationAccountId,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
