import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {}

class LoadRecentTransactionsEvent extends TransactionEvent {
  final int limit;

  const LoadRecentTransactionsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class LoadTransactionsByDateRangeEvent extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactionsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadTransactionsByTypeEvent extends TransactionEvent {
  final TransactionType type;

  const LoadTransactionsByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class LoadGroupedTransactionsEvent extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGroupedTransactionsEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Loads a single transaction by ID only (no enrichment).
/// Prefer [LoadTransactionDetailEvent] for the detail screen.
class LoadTransactionByIdEvent extends TransactionEvent {
  final String transactionId;

  const LoadTransactionByIdEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Loads a transaction AND resolves its display names in parallel:
///   - saving name from [sourceAccountId]
///   - category name + icon from [categoryId]
///   - payee info if [payeeId] is set
///   - target account name if [transferGroupId] is set
///   - commitment task name if [commitmentTaskId] is set
///
/// Emits [TransactionDetailLoaded] — never shows raw UUIDs.
class LoadTransactionDetailEvent extends TransactionEvent {
  final String transactionId;

  const LoadTransactionDetailEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class CreateTransactionEvent extends TransactionEvent {
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final TimeOfDay? time;
  final String? note;
  final String? sourceAccountId;
  final String? destinationAccountId;

  const CreateTransactionEvent({
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.time,
    this.note,
    this.sourceAccountId,
    this.destinationAccountId,
  });

  @override
  List<Object?> get props => [
    title,
    amount,
    type,
    categoryId,
    date,
    time,
    note,
    sourceAccountId,
    destinationAccountId,
  ];
}

class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class DeleteMultipleTransactionsEvent extends TransactionEvent {
  final List<String> transactionIds;

  const DeleteMultipleTransactionsEvent(this.transactionIds);

  @override
  List<Object?> get props => [transactionIds];
}

class SearchTransactionsEvent extends TransactionEvent {
  final String query;

  const SearchTransactionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends TransactionEvent {}

class FilterTransactionsByCategoryEvent extends TransactionEvent {
  final String? categoryId;

  const FilterTransactionsByCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class FilterTransactionsByTypeEvent extends TransactionEvent {
  final TransactionType? type;

  const FilterTransactionsByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class ClearFiltersEvent extends TransactionEvent {}

class RefreshTransactionsEvent extends TransactionEvent {}

class ReloadTransactionsEvent extends TransactionEvent {}
