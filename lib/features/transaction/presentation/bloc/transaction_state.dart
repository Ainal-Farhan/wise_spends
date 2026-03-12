import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

final class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

final class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

final class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;
  final TransactionType? filterType;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? filterFrom;
  final DateTime? filterTo;
  final String? dateRangeLabel;

  const TransactionLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBalance,
    this.filterType,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.filterFrom,
    this.filterTo,
    this.dateRangeLabel,
  });

  bool get hasActiveFilters =>
      filterType != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      filterFrom != null;

  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    double? totalIncome,
    double? totalExpenses,
    double? totalBalance,
    TransactionType? filterType,
    bool clearFilterType = false,
    String? searchQuery,
    bool clearSearchQuery = false,
    DateTime? filterFrom,
    bool clearFilterFrom = false,
    DateTime? filterTo,
    bool clearFilterTo = false,
    String? dateRangeLabel,
    bool clearDateRangeLabel = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalBalance: totalBalance ?? this.totalBalance,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      filterFrom: clearFilterFrom ? null : (filterFrom ?? this.filterFrom),
      filterTo: clearFilterTo ? null : (filterTo ?? this.filterTo),
      dateRangeLabel: clearDateRangeLabel
          ? null
          : (dateRangeLabel ?? this.dateRangeLabel),
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    totalIncome,
    totalExpenses,
    totalBalance,
    startDate,
    endDate,
    filterFrom,
    filterTo,
    dateRangeLabel,
  ];
}

final class RecentTransactionsLoaded extends TransactionState {
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

final class TransactionsGroupedLoaded extends TransactionState {
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

final class TransactionsFilteredLoaded extends TransactionState {
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

final class TransactionLoadedById extends TransactionState {
  final TransactionEntity transaction;
  final CommitmentTaskVO? commitmentTaskVO;
  final PayeeVO? payeeVO;

  const TransactionLoadedById(
    this.transaction, {
    this.commitmentTaskVO,
    this.payeeVO,
  });

  @override
  List<Object?> get props => [transaction, commitmentTaskVO, payeeVO];
}

final class TransactionDetailLoaded extends TransactionState {
  final TransactionEntity transaction;

  /// Resolved savings account name — e.g. "Main Savings".
  final String accountName;

  /// Resolved category name — e.g. "Food & Dining".
  final String categoryName;

  /// Resolved category icon — from [CategoryIconMapper].
  final IconData categoryIcon;

  // Transfer / commitment extras — all nullable
  final String? targetAccountName;
  final PayeeVO? payeeVO;
  final String? commitmentTaskName;

  const TransactionDetailLoaded({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
    required this.categoryIcon,
    this.targetAccountName,
    this.payeeVO,
    this.commitmentTaskName,
  });

  @override
  List<Object?> get props => [
    transaction,
    accountName,
    categoryName,
    categoryIcon,
    targetAccountName,
    payeeVO,
    commitmentTaskName,
  ];
}

final class TransactionCreated extends TransactionState {
  final TransactionEntity transaction;

  const TransactionCreated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

final class TransactionUpdated extends TransactionState {
  final TransactionEntity transaction;

  const TransactionUpdated(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

final class TransactionDeleted extends TransactionState {
  final String transactionId;

  const TransactionDeleted(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

final class MultipleTransactionsDeleted extends TransactionState {
  final List<String> transactionIds;

  const MultipleTransactionsDeleted(this.transactionIds);

  @override
  List<Object?> get props => [transactionIds];
}

final class TransactionEmpty extends TransactionState {
  final String message;

  const TransactionEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

final class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

final class TransactionSearchResults extends TransactionState {
  final String query;
  final List<TransactionEntity> searchResults;

  const TransactionSearchResults({
    required this.query,
    required this.searchResults,
  });

  @override
  List<Object?> get props => [query, searchResults];
}
