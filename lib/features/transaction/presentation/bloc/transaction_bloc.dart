import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/saving/data/repositories/i_saving_repository.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
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
    on<FilterTransactionsByDateRangeEvent>(_onFilterByDateRange);
    on<RevokeTransactionEvent>(_onRevokeTransaction);
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
      final tx = await _repository.fetchById(event.transactionId);
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
      CategoryEntity? categoryEntity;
      IconData categoryIcon = CategoryIconMapper.getIconForCategory(
        tx.category?.iconCodePoint ?? '',
      );

      if (tx.categoryId != null && tx.categoryId!.isNotEmpty) {
        try {
          final categoryRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getCategoryRepository();
          final category = await categoryRepo.findById(id: tx.categoryId!);
          if (category != null) {
            categoryEntity = CategoryEntity.from(category);
            categoryName = category.name;
            categoryIcon = CategoryIconMapper.getIconForCategory(
              category.iconCodePoint,
            );
          }
        } catch (e, stackTrace) {
          WiseLogger().debug(
            'Failed to resolve category ${tx.categoryId}',
            tag: 'TransactionBloc',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      // ── Resolve target account (transfers) ─────────────────────────────────
      String? targetAccountName;
      if (tx.destinationSavingId != null) {
        final targetSaving = await _savingRepository.getSavingById(
          tx.destinationSavingId!,
        );
        targetAccountName = targetSaving?.saving.name ?? tx.destinationSavingId;
      }

      // ── Resolve payee info ─────────────────────────────────────────────────
      PayeeVO? payeeVO;
      if (tx.payeeId != null) {
        try {
          final payeeRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getPayeeRepository();
          final payee = await payeeRepo.findById(id: tx.payeeId!);
          if (payee != null) {
            payeeVO = PayeeVO.fromExpnsPayee(payee);
          }
        } catch (e, stackTrace) {
          WiseLogger().debug(
            'Failed to resolve payee ${tx.payeeId}',
            tag: 'TransactionBloc',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      // ── Resolve commitment task name ───────────────────────────────────────
      String? commitmentTaskName;
      if (tx.commitmentTaskId != null) {
        try {
          final taskRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getCommitmentTaskRepository();
          final task = await taskRepo.findById(id: tx.commitmentTaskId!);
          commitmentTaskName = task?.name;
        } catch (e, stackTrace) {
          WiseLogger().debug(
            'Failed to resolve task ${tx.commitmentTaskId}',
            tag: 'TransactionBloc',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      emit(
        TransactionDetailLoaded(
          transaction: tx,
          accountName: accountName,
          categoryName: categoryName,
          categoryIcon: categoryIcon,
          targetAccountName: targetAccountName,
          payeeVO: payeeVO,
          commitmentTaskName: commitmentTaskName,
          categoryEntity: categoryEntity,
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
      final transaction = await _repository.fetchById(event.transactionId);
      if (transaction == null) {
        emit(const TransactionError('Transaction not found'));
      } else {
        CommitmentTaskVO? commitmentTaskVO;
        PayeeVO? payeeVO;
        if (transaction.commitmentTaskId != null) {
          final commitment =
              await SingletonUtil.getSingleton<IRepositoryLocator>()!
                  .getCommitmentTaskRepository()
                  .findById(id: transaction.commitmentTaskId!);

          if (commitment != null) {
            commitmentTaskVO = CommitmentTaskVO.fromExpnsCommitmentTask(
              commitment,
            );
          }
        }

        if (transaction.payeeId != null) {
          final payee = await SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getPayeeRepository()
              .findById(id: transaction.payeeId!);

          if (payee != null) {
            payeeVO = PayeeVO.fromExpnsPayee(payee);
          }
        }
        emit(
          TransactionLoadedById(
            transaction,
            commitmentTaskVO: commitmentTaskVO,
            payeeVO: payeeVO,
          ),
        );
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
      final transactions = await _repository.fetchAll();
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final totalIncome = await _repository.sumIncome(
        from: thirtyDaysAgo,
        to: now,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: thirtyDaysAgo,
        to: now,
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
      final transactions = await _repository.fetchRecent(limit: event.limit);
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final totalIncome = await _repository.sumIncome(
        from: thirtyDaysAgo,
        to: now,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: thirtyDaysAgo,
        to: now,
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
      final transactions = await _repository.fetchByDateRange(
        from: event.startDate,
        to: event.endDate,
      );
      final totalIncome = await _repository.sumIncome(
        from: event.startDate,
        to: event.endDate,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: event.startDate,
        to: event.endDate,
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
      final transactions = await _repository.fetchByType(event.type);
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
          ? await _repository.fetchByDateRange(
              from: event.startDate!,
              to: event.endDate!,
            )
          : await _repository.fetchAll();

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
      final totalIncome = await _repository.sumIncome(
        from: event.startDate ?? thirtyDaysAgo,
        to: event.endDate ?? now,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: event.startDate ?? thirtyDaysAgo,
        to: event.endDate ?? now,
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
        savingId: event.sourceAccountId ?? '',
        payeeId: event.payeeId,
        destinationSavingId: event.destinationAccountId,
        categoryId: event.categoryId,
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

      final created = await _repository.saveTransaction(transaction);
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
      final existing = await _repository.fetchById(event.transaction.id);

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

      final saved = await _repository.editTransaction(updated);
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
      final allTransactions = await _repository.fetchAll();
      final deletedTransaction = allTransactions.firstWhere(
        (t) => t.id == event.transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      await _repository.removeTransaction(event.transactionId);
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
      await _repository.saveTransaction(transaction);
      add(LoadTransactionsEvent());
    }
  }

  Future<void> _onDeleteMultipleTransactions(
    DeleteMultipleTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      for (final id in event.transactionIds) {
        await _repository.removeTransaction(id);
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
      final current = state is TransactionLoaded
          ? state as TransactionLoaded
          : null;

      emit(TransactionLoading());
      final allTransactions = await _repository.fetchAll();

      var filtered = allTransactions;

      // Preserve type filter
      if (current?.filterType != null) {
        filtered = filtered
            .where((t) => t.type == current!.filterType)
            .toList();
      }

      // Preserve date filter
      if (current?.filterFrom != null && current?.filterTo != null) {
        filtered = filtered
            .where(
              (t) =>
                  t.date.isAfter(
                    current!.filterFrom!.subtract(const Duration(seconds: 1)),
                  ) &&
                  t.date.isBefore(
                    current.filterTo!.add(const Duration(seconds: 1)),
                  ),
            )
            .toList();
      }

      // Apply search
      if (event.query.isNotEmpty) {
        filtered = filtered
            .where(
              (t) =>
                  t.title.toLowerCase().contains(event.query.toLowerCase()) ||
                  (t.note?.toLowerCase().contains(event.query.toLowerCase()) ??
                      false),
            )
            .toList();
      }

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final totalIncome = await _repository.sumIncome(
        from: thirtyDaysAgo,
        to: now,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: thirtyDaysAgo,
        to: now,
      );

      emit(
        TransactionLoaded(
          transactions: filtered,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          totalBalance: totalIncome - totalExpenses,
          filterType: current?.filterType,
          searchQuery: event.query,
          filterFrom: current?.filterFrom,
          filterTo: current?.filterTo,
          dateRangeLabel: current?.dateRangeLabel,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to search: ${e.toString()}'));
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
      emit(TransactionLoading());

      final transactions = await _repository.fetchAll();
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
      // Preserve existing filter state
      final current = state is TransactionLoaded
          ? state as TransactionLoaded
          : null;

      emit(TransactionLoading());

      final allTransactions = await _repository.fetchAll();
      final newFilterType = event.type;
      final existingDateFrom = current?.filterFrom;
      final existingDateTo = current?.filterTo;
      final existingSearch = current?.searchQuery;

      var filtered = allTransactions;

      // Apply type filter
      if (newFilterType != null) {
        filtered = filtered.where((t) => t.type == newFilterType).toList();
      }

      // Preserve date filter
      if (existingDateFrom != null && existingDateTo != null) {
        filtered = filtered
            .where(
              (t) =>
                  t.date.isAfter(
                    existingDateFrom.subtract(const Duration(seconds: 1)),
                  ) &&
                  t.date.isBefore(
                    existingDateTo.add(const Duration(seconds: 1)),
                  ),
            )
            .toList();
      }

      // Preserve search
      if (existingSearch != null && existingSearch.isNotEmpty) {
        filtered = filtered
            .where(
              (t) =>
                  t.title.toLowerCase().contains(
                    existingSearch.toLowerCase(),
                  ) ||
                  (t.note?.toLowerCase().contains(
                        existingSearch.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final totalIncome = await _repository.sumIncome(
        from: thirtyDaysAgo,
        to: now,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: thirtyDaysAgo,
        to: now,
      );

      emit(
        TransactionLoaded(
          transactions: filtered,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          totalBalance: totalIncome - totalExpenses,
          filterType: newFilterType,
          searchQuery: existingSearch,
          filterFrom: existingDateFrom,
          filterTo: existingDateTo,
          dateRangeLabel: current?.dateRangeLabel,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to filter: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByDateRange(
    FilterTransactionsByDateRangeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final current = state is TransactionLoaded
          ? state as TransactionLoaded
          : null;

      emit(TransactionLoading());

      final allTransactions = await _repository.fetchAll();
      final existingType = current?.filterType;
      final existingSearch = current?.searchQuery;

      var filtered = allTransactions;

      if (existingType != null) {
        filtered = filtered.where((t) => t.type == existingType).toList();
      }
      if (event.from != null && event.to != null) {
        filtered = filtered
            .where(
              (t) =>
                  t.date.isAfter(
                    event.from!.subtract(const Duration(seconds: 1)),
                  ) &&
                  t.date.isBefore(event.to!.add(const Duration(seconds: 1))),
            )
            .toList();
      }
      if (existingSearch != null && existingSearch.isNotEmpty) {
        filtered = filtered
            .where(
              (t) =>
                  t.title.toLowerCase().contains(
                    existingSearch.toLowerCase(),
                  ) ||
                  (t.note?.toLowerCase().contains(
                        existingSearch.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }

      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final totalIncome = await _repository.sumIncome(
        from: thirtyDaysAgo,
        to: now,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: thirtyDaysAgo,
        to: now,
      );

      emit(
        TransactionLoaded(
          transactions: filtered,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          totalBalance: totalIncome - totalExpenses,
          filterType: existingType,
          searchQuery: existingSearch,
          filterFrom: event.from,
          filterTo: event.to,
          dateRangeLabel: event.rangeLabel,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to filter by date: ${e.toString()}'));
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
      final transactions = await _repository.fetchAll();
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final totalIncome = await _repository.sumIncome(
        from: thirtyDaysAgo,
        to: now,
      );
      final totalExpenses = await _repository.sumExpenses(
        from: thirtyDaysAgo,
        to: now,
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

  // ============================================================================
  // REVOKE
  // ============================================================================

  Future<void> _onRevokeTransaction(
    RevokeTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.revokeTransaction(
        transactionId: event.transactionId,
        reason: event.reason,
        revokedAt: DateTime.now(),
      );
      emit(TransactionRevoked(event.transactionId));
      add(LoadTransactionsEvent());
    } catch (e) {
      emit(TransactionError('Failed to revoke transaction: ${e.toString()}'));
    }
  }
}
