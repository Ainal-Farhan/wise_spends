import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final ITransactionRepository _repository;
  final ISavingRepository _savingRepository;

  TransactionBloc(this._repository, this._savingRepository)
    : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadRecentTransactionsEvent>(_onLoadRecentTransactions);
    on<LoadTransactionsByDateRangeEvent>(_onLoadTransactionsByDateRange);
    on<LoadTransactionsByTypeEvent>(_onLoadTransactionsByType);
    on<LoadGroupedTransactionsEvent>(_onLoadGroupedTransactions);
    on<LoadTransactionByIdEvent>(_onLoadTransactionById);
    on<LoadTransactionDetailEvent>(_onLoadTransactionDetail);
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
  // DETAIL — enriched load for the detail screen
  // ============================================================================

  Future<void> _onLoadTransactionDetail(
    LoadTransactionDetailEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final tx = await _repository.getTransactionById(event.transactionId);
      if (tx == null) {
        emit(const TransactionError('Transaction not found'));
        return;
      }

      // ── Resolve source saving name ─────────────────────────────────────────
      String accountName = 'Unknown Account';
      final saving = await _savingRepository.getSavingById(tx.savingId);
      if (saving != null) accountName = saving.saving.name ?? accountName;

      // ── Resolve category name + icon ───────────────────────────────────────
      String categoryName = 'Uncategorized';
      IconData categoryIcon = CategoryIconMapper.getIconForCategory(
        tx.expenseId ?? '',
      );

      if (tx.expenseId != null && tx.expenseId!.isNotEmpty) {
        try {
          final categoryRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getCategoryRepository();
          final category = await categoryRepo.findById(id: tx.expenseId!);
          if (category != null) {
            categoryName = category.name;
            categoryIcon = CategoryIconMapper.getIconForCategory(category.name);
          }
        } catch (_) {}
      }

      // ── Resolve target account (transfers) ─────────────────────────────────
      String? targetAccountName;
      if (tx.transferGroupId != null && tx.transferType == 'debit') {
        try {
          final pairedTx = await _repository.getTransactionByTransferGroupId(
            tx.transferGroupId!,
            excludeId: tx.id,
          );
          if (pairedTx != null) {
            final targetSaving = await _savingRepository.getSavingById(
              pairedTx.savingId,
            );
            targetAccountName = targetSaving?.saving.name ?? pairedTx.savingId;
          }
        } catch (_) {}
      }

      // ── Resolve payee info ─────────────────────────────────────────────────
      String? payeeName;
      String? payeeBankName;
      String? payeeAccountNumber;
      if (tx.payeeId != null) {
        try {
          final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getPayeeRepository();
          final payee = await payeeRepo.findById(id: tx.payeeId!);
          if (payee != null) {
            payeeName = payee.name;
            payeeBankName = payee.bankName;
            payeeAccountNumber = payee.accountNumber;
          }
        } catch (_) {}
      }

      // ── Resolve commitment task name ───────────────────────────────────────
      String? commitmentTaskName;
      if (tx.commitmentTaskId != null) {
        try {
          final taskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getCommitmentTaskRepository();
          final task = await taskRepo.findById(id: tx.commitmentTaskId!);
          commitmentTaskName = task?.name;
        } catch (_) {}
      }

      emit(
        TransactionDetailLoaded(
          transaction: tx,
          accountName: accountName,
          categoryName: categoryName,
          categoryIcon: categoryIcon,
          targetAccountName: targetAccountName,
          payeeName: payeeName,
          payeeBankName: payeeBankName,
          payeeAccountNumber: payeeAccountNumber,
          commitmentTaskName: commitmentTaskName,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to load transaction: ${e.toString()}'));
    }
  }

  // ============================================================================
  // PLAIN load by ID
  // ============================================================================

  Future<void> _onLoadTransactionById(
    LoadTransactionByIdEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transaction = await _repository.getTransactionById(
        event.transactionId,
      );
      if (transaction == null) {
        emit(const TransactionError('Transaction not found'));
      } else {
        emit(TransactionLoadedById(transaction));
      }
    } catch (e) {
      emit(TransactionError('Failed to load transaction: ${e.toString()}'));
    }
  }

  // ============================================================================
  // LOAD HANDLERS
  // ============================================================================

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

      final grouped = <DateTime, List<TransactionEntity>>{};
      for (final tx in transactions) {
        final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
        grouped.putIfAbsent(date, () => []).add(tx);
      }
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
  // CREATE
  // ============================================================================

  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      DateTime transactionDateTime = event.date;
      if (event.time != null) {
        transactionDateTime = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
          event.time!.hour,
          event.time!.minute,
        );
      }

      final transaction = TransactionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        amount: event.amount,
        type: event.type,
        savingId:
            event.sourceAccountId ?? '', // ← fixed: savingId = source account
        expenseId: event.categoryId, // ← fixed: expenseId = category
        date: transactionDateTime,
        note: event.note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _savingRepository.makeTransaction(
        sourceSavingId: event.sourceAccountId!,
        destinationSavingId: event.destinationAccountId,
        amount: event.amount,
        transactionType: event.type,
        reference: event.title,
      );

      final created = await _repository.createTransaction(transaction);
      emit(TransactionCreated(created));
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to create transaction: ${e.toString()}'));
    }
  }

  // ============================================================================
  // UPDATE — only editable fields; type/amount/account are immutable post-save
  // ============================================================================

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      // Load the existing transaction so we can preserve immutable fields
      final existing = await _repository.getTransactionById(
        event.transaction.id,
      );

      if (existing == null) {
        emit(const TransactionError('Transaction not found'));
        return;
      }

      // Build updated entity — immutable fields taken from existing record,
      // editable fields taken from the incoming event
      final updated = existing.copyWith(
        // ── Editable ──────────────────────────────────────────────────────────
        title: event.transaction.title,
        date: event.transaction.date,
        note: event.transaction.note,
        // ── Immutable (preserved from original) ───────────────────────────────
        // type, amount, savingId, expenseId, transferGroupId, transferType,
        // commitmentTaskId, payeeId are intentionally NOT updated
        updatedAt: DateTime.now(),
      );

      final saved = await _repository.updateTransaction(updated);
      emit(TransactionUpdated(saved));
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to update transaction: ${e.toString()}'));
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  final Map<String, TransactionEntity> _deletedTransactionBuffer = {};

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final allTransactions = await _repository.getAllTransactions();
      final deletedTransaction = allTransactions.firstWhere(
        (t) => t.id == event.transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      await _repository.deleteTransaction(event.transactionId);
      emit(TransactionDeleted(event.transactionId));

      _deletedTransactionBuffer[event.transactionId] = deletedTransaction;
      Future.delayed(const Duration(seconds: 5), () {
        _deletedTransactionBuffer.remove(event.transactionId);
      });

      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: ${e.toString()}'));
    }
  }

  Future<void> undoDelete(String transactionId) async {
    final transaction = _deletedTransactionBuffer.remove(transactionId);
    if (transaction != null) {
      await _repository.createTransaction(transaction);
      add(LoadTransactionsEvent());
    }
  }

  Future<void> _onDeleteMultipleTransactions(
    DeleteMultipleTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      for (final id in event.transactionIds) {
        await _repository.deleteTransaction(id);
      }
      emit(MultipleTransactionsDeleted(event.transactionIds));
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to delete transactions: ${e.toString()}'));
    }
  }

  // ============================================================================
  // SEARCH & FILTER
  // ============================================================================

  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final results = await _repository.searchTransactions(event.query);
      emit(
        TransactionSearchResults(query: event.query, searchResults: results),
      );
    } catch (e) {
      emit(TransactionError('Failed to search transactions: ${e.toString()}'));
    }
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactionsEvent());
  }

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
          filterType: TransactionType.expense,
          filterCategory: event.categoryId,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to filter transactions: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByType(
    FilterTransactionsByTypeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await _repository.getAllTransactions();
      final filtered = event.type == null
          ? transactions
          : transactions.where((t) => t.type == event.type!).toList();
      emit(
        TransactionsFilteredLoaded(
          transactions: filtered,
          filterType: event.type,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to filter transactions: ${e.toString()}'));
    }
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactionsEvent());
  }

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
        RecentTransactionsLoaded(
          recentTransactions: transactions,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          totalBalance: totalIncome - totalExpenses,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to refresh transactions: ${e.toString()}'));
    }
  }

  Future<void> _onReloadTransactions(
    ReloadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactionsEvent());
  }
}
