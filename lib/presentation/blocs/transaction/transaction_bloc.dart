import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// Transaction BLoC - manages transaction state and business logic
/// Follows strict BLoC pattern: Event → BLoC → State → UI
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final ITransactionRepository _repository;

  TransactionBloc(this._repository) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadRecentTransactionsEvent>(_onLoadRecentTransactions);
    on<LoadTransactionsByDateRangeEvent>(_onLoadTransactionsByDateRange);
    on<LoadTransactionsByTypeEvent>(_onLoadTransactionsByType);
    on<LoadGroupedTransactionsEvent>(_onLoadGroupedTransactions);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<DeleteMultipleTransactionsEvent>(_onDeleteMultipleTransactions);
    on<SearchTransactionsEvent>(_onSearchTransactions);
    on<ClearSearchEvent>(_onClearSearch);
    on<FilterTransactionsByCategoryEvent>(_onFilterByCategory);
    on<FilterTransactionsByTypeEvent>(_onFilterByType);
    on<ClearFiltersEvent>(_onClearFilters);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
    on<ReloadTransactionsEvent>(_onReloadTransactions);
  }

  // ============================================================================
  // LOAD HANDLERS
  // ============================================================================

  /// Load all transactions
  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getAllTransactions();
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final totalIncome = await _repository.getTotalIncome(
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      final totalExpenses = await _repository.getTotalExpenses(
        startDate: thirtyDaysAgo,
        endDate: now,
      );

      if (transactions.isEmpty) {
        emit(
          const TransactionEmpty('No transactions yet. Start by adding one!'),
        );
      } else {
        emit(
          TransactionLoaded(
            transactions: transactions,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            totalBalance: totalIncome - totalExpenses,
          ),
        );
      }
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  /// Load recent transactions for dashboard
  Future<void> _onLoadRecentTransactions(
    LoadRecentTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await _repository.getRecentTransactions(
        limit: event.limit,
      );

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final totalIncome = await _repository.getTotalIncome(
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      final totalExpenses = await _repository.getTotalExpenses(
        startDate: thirtyDaysAgo,
        endDate: now,
      );

      emit(
        RecentTransactionsLoaded(
          recentTransactions: transactions,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          totalBalance: totalIncome - totalExpenses,
        ),
      );
    } catch (e) {
      emit(
        TransactionError('Failed to load recent transactions: ${e.toString()}'),
      );
    }
  }

  /// Load transactions by date range
  Future<void> _onLoadTransactionsByDateRange(
    LoadTransactionsByDateRangeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getTransactionsByDateRange(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      final totalIncome = await _repository.getTotalIncome(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      final totalExpenses = await _repository.getTotalExpenses(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      if (transactions.isEmpty) {
        emit(const TransactionEmpty('No transactions in this date range'));
      } else {
        emit(
          TransactionLoaded(
            transactions: transactions,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            totalBalance: totalIncome - totalExpenses,
            startDate: event.startDate,
            endDate: event.endDate,
          ),
        );
      }
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  /// Load transactions by type
  Future<void> _onLoadTransactionsByType(
    LoadTransactionsByTypeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getTransactionsByType(event.type);
      emit(
        TransactionsFilteredLoaded(
          transactions: transactions,
          filterType: event.type,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  /// Load transactions grouped by date (for history screen)
  Future<void> _onLoadGroupedTransactions(
    LoadGroupedTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = event.startDate != null && event.endDate != null
          ? await _repository.getTransactionsByDateRange(
              startDate: event.startDate!,
              endDate: event.endDate!,
            )
          : await _repository.getAllTransactions();

      // Group transactions by date
      final grouped = <DateTime, List<TransactionEntity>>{};
      for (final transaction in transactions) {
        final date = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(transaction);
      }

      // Sort dates in descending order
      final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

      final sortedGrouped = {
        for (final date in sortedDates) date: grouped[date]!,
      };

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final totalIncome = await _repository.getTotalIncome(
        startDate: event.startDate ?? thirtyDaysAgo,
        endDate: event.endDate ?? now,
      );
      final totalExpenses = await _repository.getTotalExpenses(
        startDate: event.startDate ?? thirtyDaysAgo,
        endDate: event.endDate ?? now,
      );

      if (sortedGrouped.isEmpty) {
        emit(const TransactionEmpty('No transactions found'));
      } else {
        emit(
          TransactionsGroupedLoaded(
            groupedTransactions: sortedGrouped,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            totalBalance: totalIncome - totalExpenses,
          ),
        );
      }
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  // ============================================================================
  // CREATE/UPDATE/DELETE HANDLERS
  // ============================================================================

  /// Create a new transaction
  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transaction = TransactionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        amount: event.amount,
        type: event.type,
        categoryId: event.categoryId,
        date: event.date,
        note: event.note,
        sourceAccountId: event.sourceAccountId,
        destinationAccountId: event.destinationAccountId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _repository.createTransaction(transaction);
      emit(TransactionCreated(created));

      // Reload transactions after creation
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to create transaction: ${e.toString()}'));
    }
  }

  /// Update an existing transaction
  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final updated = await _repository.updateTransaction(event.transaction);
      emit(TransactionUpdated(updated));

      // Reload transactions after update
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to update transaction: ${e.toString()}'));
    }
  }

  /// Delete a transaction with undo support
  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      // Get the transaction before deleting (for undo)
      final allTransactions = await _repository.getAllTransactions();
      final deletedTransaction = allTransactions.firstWhere(
        (t) => t.id == event.transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      await _repository.deleteTransaction(event.transactionId);
      emit(TransactionDeleted(event.transactionId));

      // Store deleted transaction for potential undo (in memory)
      _deletedTransactionBuffer[event.transactionId] = deletedTransaction;
      
      // Auto-clear buffer after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        _deletedTransactionBuffer.remove(event.transactionId);
      });

      // Reload transactions after deletion
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: ${e.toString()}'));
    }
  }

  /// Undo last deletion
  Future<void> undoDelete(String transactionId) async {
    final transaction = _deletedTransactionBuffer.remove(transactionId);
    if (transaction != null) {
      await _repository.createTransaction(transaction);
      add(LoadTransactionsEvent());
    }
  }

  // Buffer for deleted transactions (for undo functionality)
  final Map<String, dynamic> _deletedTransactionBuffer = {};

  /// Delete multiple transactions (batch delete)
  Future<void> _onDeleteMultipleTransactions(
    DeleteMultipleTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      for (final id in event.transactionIds) {
        await _repository.deleteTransaction(id);
      }
      emit(MultipleTransactionsDeleted(event.transactionIds));

      // Reload transactions after batch deletion
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to delete transactions: ${e.toString()}'));
    }
  }

  // ============================================================================
  // SEARCH & FILTER HANDLERS
  // ============================================================================

  /// Search transactions by query
  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final results = await _repository.searchTransactions(event.query);
      if (results.isEmpty) {
        emit(
          TransactionSearchResults(query: event.query, searchResults: results),
        );
      } else {
        emit(
          TransactionSearchResults(query: event.query, searchResults: results),
        );
      }
    } catch (e) {
      emit(TransactionError('Failed to search transactions: ${e.toString()}'));
    }
  }

  /// Clear search results and reload transactions
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactionsEvent());
  }

  /// Filter transactions by category
  Future<void> _onFilterByCategory(
    FilterTransactionsByCategoryEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await _repository.getAllTransactions();
      final filtered = event.categoryId == null
          ? transactions
          : transactions
                .where((t) => t.categoryId == event.categoryId)
                .toList();

      emit(
        TransactionsFilteredLoaded(
          transactions: filtered,
          filterType: TransactionType.expense, // Default, can be enhanced
          filterCategory: event.categoryId,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to filter transactions: ${e.toString()}'));
    }
  }

  /// Filter transactions by type
  Future<void> _onFilterByType(
    FilterTransactionsByTypeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await _repository.getAllTransactions();
      final filtered = event.type == null
          ? transactions
          : transactions
                .where((t) => t.type == event.type!)
                .toList();

      emit(
        TransactionsFilteredLoaded(
          transactions: filtered,
          filterType: event.type,
          filterCategory: null,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to filter transactions: ${e.toString()}'));
    }
  }

  /// Clear all filters
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactionsEvent());
  }

  // ============================================================================
  // REFRESH HANDLERS
  // ============================================================================

  /// Refresh transactions (pull-to-refresh)
  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await _repository.getAllTransactions();
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final totalIncome = await _repository.getTotalIncome(
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      final totalExpenses = await _repository.getTotalExpenses(
        startDate: thirtyDaysAgo,
        endDate: now,
      );

      emit(
        TransactionLoaded(
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          totalBalance: totalIncome - totalExpenses,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to refresh transactions: ${e.toString()}'));
    }
  }

  /// Reload data (e.g., after returning from another screen)
  Future<void> _onReloadTransactions(
    ReloadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactionsEvent());
  }
}
