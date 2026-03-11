import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/presentation/widgets/components/transaction_card.dart';
import 'package:wise_spends/router/route_arguments.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// Transaction History Screen
/// Features:
/// - Search bar (expands on tap)
/// - Filter chips (All, Income, Expense, Transfer)
/// - Grouped by date with running totals
/// - Swipe to delete with undo
/// - Pull-to-refresh
/// - Empty state with CTA
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(
        context.read<ITransactionRepository>(),
        context.read<ISavingRepository>(),
      )..add(LoadTransactionsEvent()),
      child: const _TransactionHistoryScreenContent(),
    );
  }
}

class _TransactionHistoryScreenContent extends StatefulWidget {
  const _TransactionHistoryScreenContent();

  @override
  State<_TransactionHistoryScreenContent> createState() =>
      _TransactionHistoryScreenContentState();
}

class _TransactionHistoryScreenContentState
    extends State<_TransactionHistoryScreenContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        _searchController.clear();

        if (state is TransactionLoaded) {
          _searchController.text = state.searchQuery ?? '';
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.get('transaction.history')),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchBottomSheet(context),
              tooltip: loc.get('general.search'),
              constraints: const BoxConstraints(
                minWidth: AppTouchTarget.min,
                minHeight: AppTouchTarget.min,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterBottomSheet(context),
              tooltip: loc.get('general.filter'),
              constraints: const BoxConstraints(
                minWidth: AppTouchTarget.min,
                minHeight: AppTouchTarget.min,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(RefreshTransactionsEvent());
          },
          child: CustomScrollView(
            slivers: [
              // Filter chips
              SliverToBoxAdapter(child: _buildFilterChips()),

              // Search query indicator
              SliverToBoxAdapter(child: _buildActiveFiltersBar()),

              // Transaction list
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoading) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ShimmerTransactionItem(),
                          childCount: 10,
                        ),
                      );
                    } else if (state is TransactionLoaded) {
                      final transactions = state.transactions;
                      final filterType = state.filterType;
                      final searchQuery = state.searchQuery;

                      if (transactions.isEmpty) {
                        return SliverToBoxAdapter(
                          child: NoTransactionsEmptyState(
                            onAddTransaction: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addTransaction,
                                arguments: AddTransactionArgs(),
                              );
                            },
                          ),
                        );
                      }

                      // Apply filters
                      var filtered = _applyFilters(
                        transactions,
                        filterType,
                        searchQuery,
                      );

                      if (filtered.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xxxl),
                            child: NoSearchResultsEmptyState(),
                          ),
                        );
                      }

                      // Group by date
                      return _buildGroupedList(filtered);
                    } else if (state is TransactionsFilteredLoaded) {
                      final transactions = state.transactions;
                      final filterType = state.filterType;

                      if (transactions.isEmpty) {
                        return SliverToBoxAdapter(
                          child: NoTransactionsEmptyState(
                            onAddTransaction: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addTransaction,
                                arguments: AddTransactionArgs(),
                              );
                            },
                          ),
                        );
                      }

                      // Apply filters
                      var filtered = _applyFilters(
                        transactions,
                        filterType,
                        null,
                      );

                      if (filtered.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xxxl),
                            child: NoSearchResultsEmptyState(),
                          ),
                        );
                      }

                      // Group by date
                      return _buildGroupedList(filtered);
                    } else if (state is TransactionError) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          child: ErrorStateWidget(
                            message: state.message,
                            onAction: () {
                              context.read<TransactionBloc>().add(
                                LoadTransactionsEvent(),
                              );
                            },
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ),

              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.addTransaction,
              arguments: AddTransactionArgs(),
            );
          },
          elevation: AppElevation.sm,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        TransactionType? currentFilterType;
        if (state is TransactionLoaded) {
          currentFilterType = state.filterType;
        } else if (state is TransactionsFilteredLoaded) {
          currentFilterType = state.filterType;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // "All" chip
              Expanded(
                child: _FilterTab(
                  label: 'All',
                  icon: Icons.all_inclusive,
                  color: AppColors.textSecondary,
                  isSelected: currentFilterType == null,
                  onTap: () => context.read<TransactionBloc>().add(
                    FilterTransactionsByTypeEvent(null),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // One chip per TransactionType
              ...TransactionType.values.expand(
                (type) => [
                  Expanded(
                    child: _FilterTab(
                      label: type.label,
                      icon: type.icon,
                      color: type.color,
                      isSelected: currentFilterType == type,
                      onTap: () => context.read<TransactionBloc>().add(
                        FilterTransactionsByTypeEvent(
                          currentFilterType == type ? null : type,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<TransactionEntity> _applyFilters(
    List<TransactionEntity> transactions,
    TransactionType? filterType,
    String? searchQuery,
  ) {
    var filtered = transactions;
    if (filterType != null) {
      filtered = filtered.where((t) => t.type == filterType).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (t.note?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                    false),
          )
          .toList();
    }

    return filtered;
  }

  Widget _buildGroupedList(List<TransactionEntity> transactions) {
    // Group by date
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

    // Sort dates descending
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final date = sortedDates[index];
        final transactionsForDate = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header with running total
            _buildDateHeader(date, transactionsForDate),
            const SizedBox(height: AppSpacing.sm),
            // Transactions for this date
            ...transactionsForDate.map(
              (transaction) => SwipeableTransactionCard(
                title: transaction.title,
                amount: transaction.amount,
                type: transaction.type,
                icon: transaction.categoryId != null
                    ? CategoryIconMapper.getIconForCategory(
                        transaction.categoryId ?? '',
                      )
                    : transaction.type.icon,
                date: transaction.date,
                note: transaction.note,
                showBudgetPlanIndicator:
                    transaction.type == TransactionType.budgetPlan,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.transactionDetail,
                    arguments: TransactionDetailArgs(transaction.id),
                  );
                },
                onDelete: () {
                  context.read<TransactionBloc>().add(
                    DeleteTransactionEvent(transaction.id),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      }, childCount: sortedDates.length),
    );
  }

  Widget _buildDateHeader(DateTime date, List<TransactionEntity> transactions) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalTransfer = transactions
        .where((t) => t.type == TransactionType.transfer)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalCommitment = transactions
        .where((t) => t.type == TransactionType.commitment)
        .fold(0.0, (sum, t) => sum + t.amount);

    final netAmount = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDateHeader(date), style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${transactions.length} ${transactions.length == 1 ? 'transaction' : 'transactions'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Net amount (income - expense)
              Text(
                NumberFormat.currency(
                  symbol: 'RM',
                  decimalDigits: 2,
                ).format(netAmount),
                style: AppTextStyles.amountSmall.copyWith(
                  color: netAmount >= 0 ? AppColors.income : AppColors.expense,
                ),
              ),

              // Income / expense breakdown
              if (totalIncome > 0 || totalExpense > 0)
                Text(
                  '↑${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(totalIncome)}'
                  ' ↓${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(totalExpense)}',
                  style: AppTextStyles.captionSmall,
                ),

              // Transfer row — only when present
              if (totalTransfer > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TransactionType.transfer.icon,
                      size: 10,
                      color: TransactionType.transfer.color,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      NumberFormat.currency(
                        symbol: 'RM',
                        decimalDigits: 2,
                      ).format(totalTransfer),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: TransactionType.transfer.color,
                      ),
                    ),
                  ],
                ),

              // Commitment row — only when present
              if (totalCommitment > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TransactionType.commitment.icon,
                      size: 10,
                      color: TransactionType.commitment.color,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      NumberFormat.currency(
                        symbol: 'RM',
                        decimalDigits: 2,
                      ).format(totalCommitment),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: TransactionType.commitment.color,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'transaction.history.today'.tr;
    } else if (transactionDate == yesterday) {
      return 'general.yesterday'.tr;
    } else {
      final daysAgo = today.difference(transactionDate).inDays;
      if (daysAgo < 7) {
        return DateFormat('EEEE').format(date);
      }
      return DateFormat('MMM d, y').format(date);
    }
  }

  Widget _buildActiveFiltersBar() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) return const SizedBox.shrink();
        if (!state.hasActiveFilters) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_alt, size: 14, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    if (state.filterType != null)
                      _ActiveFilterChip(
                        label: state.filterType!.label,
                        color: state.filterType!.color,
                        onRemove: () => context.read<TransactionBloc>().add(
                          FilterTransactionsByTypeEvent(null),
                        ),
                      ),
                    if (state.dateRangeLabel != null)
                      _ActiveFilterChip(
                        label: state.dateRangeLabel!,
                        color: AppColors.primary,
                        onRemove: () => context.read<TransactionBloc>().add(
                          FilterTransactionsByDateRangeEvent(),
                        ),
                      ),
                    if (state.searchQuery != null &&
                        state.searchQuery!.isNotEmpty)
                      _ActiveFilterChip(
                        label: '"${state.searchQuery}"',
                        color: AppColors.primary,
                        onRemove: () {
                          context.read<TransactionBloc>().add(
                            ClearSearchEvent(),
                          );
                          _searchController.clear();
                        },
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  context.read<TransactionBloc>().add(ClearFiltersEvent());
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear all',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final bloc = context.read<TransactionBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) => Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: Column(
              children: [
                // ── Handle ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Scrollable body ───────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      0,
                      AppSpacing.xxl,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Date Range ──────────────────────────────────
                        Text(
                          'transaction.history.date_range'.tr,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _buildDateRangeOption(
                              ctx,
                              bloc,
                              'transaction.history.today'.tr,
                              () {
                                final now = DateTime.now();
                                bloc.add(
                                  FilterTransactionsByDateRangeEvent(
                                    from: DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                    ),
                                    to: DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      23,
                                      59,
                                      59,
                                    ),
                                    rangeLabel: 'transaction.history.today'.tr,
                                  ),
                                );
                              },
                            ),
                            _buildDateRangeOption(
                              ctx,
                              bloc,
                              'transaction.history.this_week'.tr,
                              () {
                                final now = DateTime.now();
                                final start = now.subtract(
                                  Duration(days: now.weekday - 1),
                                );
                                bloc.add(
                                  FilterTransactionsByDateRangeEvent(
                                    from: DateTime(
                                      start.year,
                                      start.month,
                                      start.day,
                                    ),
                                    to: now,
                                    rangeLabel:
                                        'transaction.history.this_week'.tr,
                                  ),
                                );
                              },
                            ),
                            _buildDateRangeOption(
                              ctx,
                              bloc,
                              'transaction.history.this_month'.tr,
                              () {
                                final now = DateTime.now();
                                bloc.add(
                                  FilterTransactionsByDateRangeEvent(
                                    from: DateTime(now.year, now.month, 1),
                                    to: now,
                                    rangeLabel:
                                        'transaction.history.this_month'.tr,
                                  ),
                                );
                              },
                            ),
                            _buildDateRangeOption(
                              ctx,
                              bloc,
                              'transaction.history.custom_range'.tr,
                              () async {
                                Navigator.pop(ctx);
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) => Theme(
                                    data: Theme.of(context),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  bloc.add(
                                    FilterTransactionsByDateRangeEvent(
                                      from: picked.start,
                                      to: DateTime(
                                        picked.end.year,
                                        picked.end.month,
                                        picked.end.day,
                                        23,
                                        59,
                                        59,
                                      ),
                                      rangeLabel:
                                          '${DateFormat('MMM d').format(picked.start)} – '
                                          '${DateFormat('MMM d').format(picked.end)}',
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // ── Transaction Type ────────────────────────────
                        Text(
                          'transaction.history.transaction_type'.tr,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildFilterOption(
                          ctx,
                          label: 'All Transactions',
                          type: null,
                          icon: Icons.all_inclusive,
                          color: AppColors.textSecondary,
                        ),
                        ...TransactionType.values.expand(
                          (t) => [
                            _buildFilterOption(
                              ctx,
                              label: t.label,
                              type: t,
                              icon: t.icon,
                              color: t.color,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Clear all button ────────────────────────────
                        AppButton.secondary(
                          label: 'transaction.history.clear_filters'.tr,
                          onPressed: () {
                            bloc.add(ClearFiltersEvent());
                            Navigator.pop(ctx);
                          },
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeOption(
    BuildContext ctx,
    TransactionBloc bloc,
    String label,
    VoidCallback onTap,
  ) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isSelected =
            state is TransactionLoaded && state.dateRangeLabel == label;

        return GestureDetector(
          onTap: () {
            onTap();
            if (label != 'Custom Range') Navigator.pop(ctx);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext ctx, {
    required String label,
    required TransactionType? type,
    required IconData icon,
    required Color color,
  }) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        TransactionType? currentFilterType;
        if (state is TransactionLoaded) currentFilterType = state.filterType;

        final isSelected = currentFilterType == type;

        return ListTile(
          minLeadingWidth: AppTouchTarget.min,
          leading: Container(
            width: AppTouchTarget.min,
            height: AppTouchTarget.min,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: color)
              : const Icon(Icons.chevron_right),
          onTap: () {
            context.read<TransactionBloc>().add(
              FilterTransactionsByTypeEvent(type),
            );
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    final bloc = context.read<TransactionBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xxl,
            bottom: AppSpacing.xxl + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('transaction.history.search'.tr, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _searchController,
                label: 'Search',
                hint: 'Search by title or note',
                prefixIcon: Icons.search,
                showClearButton: true,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Clear',
                      onPressed: () {
                        _searchController.clear();
                        context.read<TransactionBloc>().add(ClearSearchEvent());
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      label: 'Done',
                      onPressed: () {
                        context.read<TransactionBloc>().add(
                          SearchTransactionsEvent(_searchController.text),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(height: 3),
            Text(
              // Shorten labels to fit narrow columns
              _shortLabel(label),
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _shortLabel(String label) {
    switch (label) {
      case 'Income':
        return 'Income';
      case 'Expense':
        return 'Expense';
      case 'Transfer':
        return 'Transfer';
      case 'Commitment':
        return 'Commit';
      default:
        return label;
    }
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 12, color: color),
          ),
        ],
      ),
    );
  }
}
