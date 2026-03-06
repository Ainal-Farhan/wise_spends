import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;
  final TransactionType? filterType;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBalance,
    this.filterType,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    transactions,
    totalIncome,
    totalExpenses,
    totalBalance,
    startDate,
    endDate,
  ];
}

class RecentTransactionsLoaded extends TransactionState {
  final List<TransactionEntity> recentTransactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;

  const RecentTransactionsLoaded({
    required this.recentTransactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBalance,
  });

  @override
  List<Object?> get props => [
    recentTransactions,
    totalIncome,
    totalExpenses,
    totalBalance,
  ];
}

class TransactionsGroupedLoaded extends TransactionState {
  final Map<DateTime, List<TransactionEntity>> groupedTransactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;

  const TransactionsGroupedLoaded({
    required this.groupedTransactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBalance,
  });

  @override
  List<Object?> get props => [
    groupedTransactions,
    totalIncome,
    totalExpenses,
    totalBalance,
  ];
}

class TransactionsFilteredLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final TransactionType? filterType;
  final String? filterCategory;

  const TransactionsFilteredLoaded({
    required this.transactions,
    this.filterType,
    this.filterCategory,
  });

  @override
  List<Object?> get props => [transactions, filterType, filterCategory];
}

/// Plain loaded-by-id state — still emitted for backward compat.
/// Prefer [TransactionDetailLoaded] for the detail screen.
class TransactionLoadedById extends TransactionState {
  final TransactionEntity transaction;

  const TransactionLoadedById(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

/// Enriched detail state — carries the resolved display strings so
/// the screen never has to show raw UUIDs.
///
/// Emitted by [LoadTransactionDetailEvent] after parallel lookups for:
///   - saving name (replaces sourceAccountId UUID)
///   - category name + icon (replaces categoryId UUID)
///   - payee info (for third-party commitment payments)
///   - commitment task name (for commitment transactions)
///   - target account name (for transfers)
class TransactionDetailLoaded extends TransactionState {
  final TransactionEntity transaction;

  /// Resolved savings account name — e.g. "Main Savings".
  final String accountName;

  /// Resolved category name — e.g. "Food & Dining".
  final String categoryName;

  /// Resolved category icon — from [CategoryIconMapper].
  final IconData categoryIcon;

  // Transfer / commitment extras — all nullable
  final String? targetAccountName;
  final String? payeeName;
  final String? payeeBankName;
  final String? payeeAccountNumber;
  final String? commitmentTaskName;

  const TransactionDetailLoaded({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
    required this.categoryIcon,
    this.targetAccountName,
    this.payeeName,
    this.payeeBankName,
    this.payeeAccountNumber,
    this.commitmentTaskName,
  });

  @override
  List<Object?> get props => [
    transaction,
    accountName,
    categoryName,
    categoryIcon,
    targetAccountName,
    payeeName,
    payeeBankName,
    payeeAccountNumber,
    commitmentTaskName,
  ];
}

class TransactionCreated extends TransactionState {
  final TransactionEntity transaction;

  const TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionState {
  final TransactionEntity transaction;

  const TransactionUpdated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionState {
  final String transactionId;

  const TransactionDeleted(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class MultipleTransactionsDeleted extends TransactionState {
  final List<String> transactionIds;

  const MultipleTransactionsDeleted(this.transactionIds);

  @override
  List<Object?> get props => [transactionIds];
}

class TransactionEmpty extends TransactionState {
  final String message;

  const TransactionEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionSearchResults extends TransactionState {
  final String query;
  final List<TransactionEntity> searchResults;

  const TransactionSearchResults({
    required this.query,
    required this.searchResults,
  });

  @override
  List<Object?> get props => [query, searchResults];
}
