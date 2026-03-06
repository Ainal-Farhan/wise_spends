import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, transfer, commitment }

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;

  // Relations
  final String savingId;
  final String? expenseId;
  final String? commitmentTaskId;
  final String? payeeId;

  // Transfer Logic
  final String? transferGroupId;
  final String? transferType;

  // Metadata
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
    this.expenseId,
    this.commitmentTaskId,
    this.payeeId,
    this.transferGroupId,
    this.transferType,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Convenience aliases ────────────────────────────────────────────────────

  /// Alias for [savingId] — used by screens that refer to the source account.
  String get sourceAccountId => savingId;

  /// Alias for [savingId] — kept for backward-compat call sites using savingIds.
  String get savingIds => savingId;

  /// Alias for [expenseId] — used by screens and blocs that refer to categoryId.
  String? get categoryId => expenseId;

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    type,
    savingId,
    expenseId,
    commitmentTaskId,
    payeeId,
    transferGroupId,
    transferType,
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
    String? expenseId,
    String? commitmentTaskId,
    String? payeeId,
    String? transferGroupId,
    String? transferType,
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
      expenseId: expenseId ?? this.expenseId,
      commitmentTaskId: commitmentTaskId ?? this.commitmentTaskId,
      payeeId: payeeId ?? this.payeeId,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      transferType: transferType ?? this.transferType,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
