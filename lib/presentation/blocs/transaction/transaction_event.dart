import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Transaction BLoC events
/// All user actions and system events that trigger state changes
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// LOAD EVENTS
// ============================================================================

/// Load all transactions
class LoadTransactionsEvent extends TransactionEvent {}

/// Load recent transactions for dashboard
class LoadRecentTransactionsEvent extends TransactionEvent {
  final int limit;

  const LoadRecentTransactionsEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

/// Load transactions by date range
class LoadTransactionsByDateRangeEvent extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactionsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

/// Load transactions by type
class LoadTransactionsByTypeEvent extends TransactionEvent {
  final TransactionType type;

  const LoadTransactionsByTypeEvent(this.type);

  @override
  List<Object> get props => [type];
}

/// Load transactions grouped by date (for history screen)
class LoadGroupedTransactionsEvent extends TransactionEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGroupedTransactionsEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load transaction by ID
class LoadTransactionByIdEvent extends TransactionEvent {
  final String transactionId;

  const LoadTransactionByIdEvent(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

// ============================================================================
// CREATE/UPDATE/DELETE EVENTS
// ============================================================================

/// Create a new transaction
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

/// Update an existing transaction
class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

/// Delete a transaction
class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

/// Delete multiple transactions (batch delete)
class DeleteMultipleTransactionsEvent extends TransactionEvent {
  final List<String> transactionIds;

  const DeleteMultipleTransactionsEvent(this.transactionIds);

  @override
  List<Object> get props => [transactionIds];
}

// ============================================================================
// SEARCH & FILTER EVENTS
// ============================================================================

/// Search transactions by query
class SearchTransactionsEvent extends TransactionEvent {
  final String query;

  const SearchTransactionsEvent(this.query);

  @override
  List<Object> get props => [query];
}

/// Clear search results and reload transactions
class ClearSearchEvent extends TransactionEvent {}

/// Filter transactions by category
class FilterTransactionsByCategoryEvent extends TransactionEvent {
  final String? categoryId;

  const FilterTransactionsByCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Filter transactions by type
class FilterTransactionsByTypeEvent extends TransactionEvent {
  final TransactionType? type;

  const FilterTransactionsByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

/// Clear all filters
class ClearFiltersEvent extends TransactionEvent {}

// ============================================================================
// REFRESH EVENTS
// ============================================================================

/// Refresh transactions (pull-to-refresh)
class RefreshTransactionsEvent extends TransactionEvent {}

/// Reload data (e.g., after returning from another screen)
class ReloadTransactionsEvent extends TransactionEvent {}
