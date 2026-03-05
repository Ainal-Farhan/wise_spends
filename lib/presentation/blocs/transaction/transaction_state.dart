import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Transaction BLoC states
/// Represents all possible UI states for transaction-related screens
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// INITIAL & LOADING STATES
// ============================================================================

/// Initial state - before any data is loaded
class TransactionInitial extends TransactionState {}

/// Loading state - data is being fetched
class TransactionLoading extends TransactionState {}

/// Loading more items (pagination)
class TransactionLoadingMore extends TransactionState {}

// ============================================================================
// SUCCESS STATES
// ============================================================================

/// All transactions loaded successfully
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionLoaded({
    required this.transactions,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.totalBalance = 0,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpenses, totalBalance, startDate, endDate];

  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    double? totalIncome,
    double? totalExpenses,
    double? totalBalance,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalBalance: totalBalance ?? this.totalBalance,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Recent transactions loaded (for dashboard)
class RecentTransactionsLoaded extends TransactionState {
  final List<TransactionEntity> recentTransactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;

  const RecentTransactionsLoaded({
    required this.recentTransactions,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.totalBalance = 0,
  });

  @override
  List<Object> get props => [recentTransactions, totalIncome, totalExpenses, totalBalance];
}

/// Transactions grouped by date (for history screen with sticky headers)
class TransactionsGroupedLoaded extends TransactionState {
  final Map<DateTime, List<TransactionEntity>> groupedTransactions;
  final double totalIncome;
  final double totalExpenses;
  final double totalBalance;

  const TransactionsGroupedLoaded({
    required this.groupedTransactions,
    this.totalIncome = 0,
    this.totalExpenses = 0,
    this.totalBalance = 0,
  });

  @override
  List<Object> get props => [groupedTransactions, totalIncome, totalExpenses, totalBalance];
}

/// Transactions filtered by type
class TransactionsFilteredLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final TransactionType filterType;
  final String? filterCategory;

  const TransactionsFilteredLoaded({
    required this.transactions,
    required this.filterType,
    this.filterCategory,
  });

  @override
  List<Object?> get props => [transactions, filterType, filterCategory];
}

// ============================================================================
// SEARCH STATES
// ============================================================================

/// Search results
class TransactionSearchResults extends TransactionState {
  final String query;
  final List<TransactionEntity> searchResults;

  const TransactionSearchResults({
    required this.query,
    required this.searchResults,
  });

  @override
  List<Object> get props => [query, searchResults];
}

// ============================================================================
// MUTATION STATES (CREATE/UPDATE/DELETE)
// ============================================================================

/// Transaction created successfully
class TransactionCreated extends TransactionState {
  final TransactionEntity transaction;

  const TransactionCreated(this.transaction);

  @override
  List<Object> get props => [transaction];
}

/// Transaction updated successfully
class TransactionUpdated extends TransactionState {
  final TransactionEntity transaction;

  const TransactionUpdated(this.transaction);

  @override
  List<Object> get props => [transaction];
}

/// Transaction deleted successfully
class TransactionDeleted extends TransactionState {
  final String transactionId;

  const TransactionDeleted(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

/// Multiple transactions deleted successfully
class MultipleTransactionsDeleted extends TransactionState {
  final List<String> transactionIds;

  const MultipleTransactionsDeleted(this.transactionIds);

  @override
  List<Object> get props => [transactionIds];
}

// ============================================================================
// ERROR STATES
// ============================================================================

/// Error state with message
class TransactionError extends TransactionState {
  final String message;
  final String? errorCode;

  const TransactionError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// Empty state (no transactions found)
class TransactionEmpty extends TransactionState {
  final String message;

  const TransactionEmpty([this.message = 'No transactions found']);

  @override
  List<Object> get props => [message];
}

// ============================================================================
// HELPER EXTENSIONS
// ============================================================================

extension TransactionStateX on TransactionState {
  /// Check if state is in loading condition
  bool get isLoading => this is TransactionLoading || this is TransactionLoadingMore;

  /// Check if state has data
  bool get hasData =>
      this is TransactionLoaded ||
      this is RecentTransactionsLoaded ||
      this is TransactionsGroupedLoaded ||
      this is TransactionsFilteredLoaded;

  /// Check if state is an error
  bool get isError => this is TransactionError;

  /// Check if state is empty
  bool get isEmpty => this is TransactionEmpty;
}
