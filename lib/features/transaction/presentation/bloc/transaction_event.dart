import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTransactionsEvent extends TransactionEvent {
  const LoadTransactionsEvent();
}

final class LoadRecentTransactionsEvent extends TransactionEvent {
  final int limit;

  const LoadRecentTransactionsEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

final class LoadTransactionsByDateRangeEvent extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactionsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

final class LoadTransactionsByTypeEvent extends TransactionEvent {
  final TransactionType type;

  const LoadTransactionsByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

final class LoadGroupedTransactionsEvent extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGroupedTransactionsEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

final class LoadTransactionByIdEvent extends TransactionEvent {
  final String transactionId;

  const LoadTransactionByIdEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

final class LoadTransactionDetailEvent extends TransactionEvent {
  final String transactionId;

  const LoadTransactionDetailEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

final class CreateTransactionEvent extends TransactionEvent {
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final TimeOfDay? time;
  final String? note;
  final String? sourceAccountId;
  final String? destinationAccountId;
  final String? payeeId;

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
    this.payeeId,
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
    payeeId,
  ];
}

final class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

final class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

final class DeleteMultipleTransactionsEvent extends TransactionEvent {
  final List<String> transactionIds;

  const DeleteMultipleTransactionsEvent(this.transactionIds);

  @override
  List<Object?> get props => [transactionIds];
}

final class SearchTransactionsEvent extends TransactionEvent {
  final String query;

  const SearchTransactionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

final class ClearSearchEvent extends TransactionEvent {
  const ClearSearchEvent();
}

final class FilterTransactionsByCategoryEvent extends TransactionEvent {
  final String? categoryId;

  const FilterTransactionsByCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

final class FilterTransactionsByTypeEvent extends TransactionEvent {
  final TransactionType? type;

  const FilterTransactionsByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

final class FilterTransactionsByDateRangeEvent extends TransactionEvent {
  final DateTime? from;
  final DateTime? to;
  final String? rangeLabel;

  const FilterTransactionsByDateRangeEvent({
    this.from,
    this.to,
    this.rangeLabel,
  });

  @override
  List<Object?> get props => [from, to, rangeLabel];
}

final class ClearFiltersEvent extends TransactionEvent {
  const ClearFiltersEvent();
}

final class RefreshTransactionsEvent extends TransactionEvent {
  const RefreshTransactionsEvent();
}

final class ReloadTransactionsEvent extends TransactionEvent {
  const ReloadTransactionsEvent();
}
