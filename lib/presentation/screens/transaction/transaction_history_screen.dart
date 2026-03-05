import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
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
      create: (context) =>
          TransactionBloc(context.read<ITransactionRepository>())
            ..add(LoadTransactionsEvent()),
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

    return Scaffold(
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
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),

            // Search query indicator
            SliverToBoxAdapter(
              child: _buildSearchIndicator(),
            ),

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
                    var filtered = _applyFilters(transactions, filterType, searchQuery);

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
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All',
              type: null,
              icon: Icons.all_inclusive,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: 'Income',
              type: TransactionType.income,
              icon: Icons.arrow_downward,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: 'Expense',
              type: TransactionType.expense,
              icon: Icons.arrow_upward,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: 'Transfer',
              type: TransactionType.transfer,
              icon: Icons.swap_horiz,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required TransactionType? type,
    required IconData icon,
  }) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        TransactionType? currentFilterType;
        if (state is TransactionLoaded) {
          currentFilterType = state.filterType;
        } else if (state is TransactionsFilteredLoaded) {
          currentFilterType = state.filterType;
        }
        
        final isSelected = currentFilterType == type;
        final color = _getColorForType(type);

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppIconSize.xs, color: isSelected ? Colors.white : color),
              const SizedBox(width: AppSpacing.xs),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            context.read<TransactionBloc>().add(
              FilterTransactionsByTypeEvent(selected ? type : null),
            );
          },
          selectedColor: color,
          checkmarkColor: Colors.white,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : color,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        );
      },
    );
  }

  Color _getColorForType(TransactionType? type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
      case null:
        return AppColors.textSecondary;
    }
  }

  Widget _buildSearchIndicator() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        String? searchQuery;
        if (state is TransactionLoaded) {
          searchQuery = state.searchQuery;
        }
        
        if (searchQuery == null || searchQuery.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: AppIconSize.sm, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Searching for "$searchQuery"',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear, size: AppIconSize.xs),
                onPressed: () {
                  context.read<TransactionBloc>().add(ClearSearchEvent());
                  _searchController.clear();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppTouchTarget.min,
                  minHeight: AppTouchTarget.min,
                ),
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
      delegate: SliverChildBuilderDelegate(
        (context, index) {
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
                  icon: CategoryIconMapper.getIconForCategory(
                    transaction.categoryId,
                  ),
                  date: transaction.date,
                  note: transaction.note,
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
        },
        childCount: sortedDates.length,
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, List<TransactionEntity> transactions) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
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
                Text(
                  _formatDateHeader(date),
                  style: AppTextStyles.h3,
                ),
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
              Text(
                NumberFormat.currency(symbol: 'RM', decimalDigits: 2).format(netAmount),
                style: AppTextStyles.amountSmall.copyWith(
                  color: netAmount >= 0 ? AppColors.income : AppColors.expense,
                ),
              ),
              if (totalIncome > 0 || totalExpense > 0)
                Text(
                  '↑${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(totalIncome)} ↓${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(totalExpense)}',
                  style: AppTextStyles.captionSmall,
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
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      final daysAgo = today.difference(transactionDate).inDays;
      if (daysAgo < 7) {
        return DateFormat('EEEE').format(date);
      }
      return DateFormat('MMM d, y').format(date);
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
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
            Text(
              'Filter Transactions',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFilterOption(
              context,
              label: 'All Transactions',
              type: null,
              icon: Icons.all_inclusive,
              color: AppColors.textSecondary,
            ),
            _buildFilterOption(
              context,
              label: 'Income',
              type: TransactionType.income,
              icon: Icons.arrow_downward,
              color: AppColors.income,
            ),
            _buildFilterOption(
              context,
              label: 'Expense',
              type: TransactionType.expense,
              icon: Icons.arrow_upward,
              color: AppColors.expense,
            ),
            _buildFilterOption(
              context,
              label: 'Transfer',
              type: TransactionType.transfer,
              icon: Icons.swap_horiz,
              color: AppColors.transfer,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton.secondary(
              label: 'Clear Filter',
              onPressed: () {
                context.read<TransactionBloc>().add(
                  FilterTransactionsByTypeEvent(null),
                );
                Navigator.pop(context);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required String label,
    required TransactionType? type,
    required IconData icon,
    required Color color,
  }) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        TransactionType? currentFilterType;
        if (state is TransactionLoaded) {
          currentFilterType = state.filterType;
        }
        
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
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
            Text(
              'Search Transactions',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _searchController,
              label: 'Search',
              hint: 'Search by title or note',
              prefixIcon: Icons.search,
              showClearButton: true,
              autofocus: true,
              onChanged: (value) {
                context.read<TransactionBloc>().add(
                  SearchTransactionsEvent(value),
                );
              },
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
