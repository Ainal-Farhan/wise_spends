import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/presentation/widgets/components/empty_state_widget.dart';
import 'package:wise_spends/presentation/widgets/components/transaction_card.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/router/route_arguments.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// New enhanced Home/Dashboard screen
/// Features:
/// - Greeting with time-based personalization
/// - Balance overview cards (Total, Income, Expenses)
/// - Recent transactions list
/// - Quick action FAB
/// - Pull-to-refresh
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TransactionBloc(context.read<ITransactionRepository>())
            ..add(LoadRecentTransactionsEvent(limit: 10)),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TransactionBloc>().add(RefreshTransactionsEvent());
        },
        child: CustomScrollView(
          slivers: [
            // App Bar with greeting
            SliverAppBar(
              floating: true,
              backgroundColor: WiseSpendsColors.background,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WiseSpendsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'WiseSpends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: WiseSpendsColors.textPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Navigate to notifications screen
                    // AppRouter.navigateTo(context, AppRoutes.notifications);
                  },
                  tooltip: 'Notifications',
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance overview cards
                    _buildBalanceOverview(context),
                    const SizedBox(height: 24),

                    // Section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all transactions screen
                            AppRouter.navigateTo(
                              context,
                              AppRoutes.transactionHistory,
                              arguments: const TransactionHistoryArgs(),
                            );
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Recent transactions list
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is TransactionLoading) {
                          return const TransactionListShimmer(itemCount: 5);
                        } else if (state is RecentTransactionsLoaded) {
                          if (state.recentTransactions.isEmpty) {
                            return NoTransactionsEmptyState(
                              onAddTransaction: () {
                                AppRouter.navigateTo(
                                  context,
                                  AppRoutes.addTransaction,
                                  arguments: const AddTransactionArgs(),
                                );
                              },
                            );
                          }
                          return _buildTransactionList(
                            context,
                            state.recentTransactions,
                          );
                        } else if (state is TransactionError) {
                          return _buildErrorState(context, state.message);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDialFAB(context),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildBalanceOverview(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded || state is TransactionLoading) {
          final totalIncome = state is TransactionLoaded
              ? state.totalIncome
              : 0.0;
          final totalExpenses = state is TransactionLoaded
              ? state.totalExpenses
              : 0.0;
          final totalBalance = totalIncome - totalExpenses;

          return Column(
            children: [
              // Main balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      WiseSpendsColors.primary,
                      WiseSpendsColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: WiseSpendsColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        symbol: 'RM ',
                        decimalDigits: 2,
                      ).format(totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Income and Expense cards
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      context,
                      title: 'Income',
                      amount: totalIncome,
                      type: TransactionType.income,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBalanceCard(
                      context,
                      title: 'Expenses',
                      amount: totalExpenses,
                      type: TransactionType.expense,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const Column(
          children: [
            BalanceCardShimmer(),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: BalanceCardShimmer()),
                SizedBox(width: 12),
                Expanded(child: BalanceCardShimmer()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(
    BuildContext context, {
    required String title,
    required double amount,
    required TransactionType type,
    required IconData icon,
  }) {
    final color = type == TransactionType.income
        ? WiseSpendsColors.success
        : WiseSpendsColors.secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(
              symbol: 'RM ',
              decimalDigits: 2,
            ).format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionEntity> transactions,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCard(
          title: transaction.title,
          amount: transaction.amount,
          type: transaction.type,
          icon: CategoryIconMapper.getIconForCategory(transaction.categoryId),
          date: transaction.date,
          note: transaction.note,
          onTap: () {
            // Navigate to transaction details
            AppRouter.navigateTo(
              context,
              AppRoutes.transactionDetail,
              arguments: TransactionDetailArgs(transaction.id),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: WiseSpendsColors.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                LoadRecentTransactionsEvent(),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showTransactionTypeDialog(context);
      },
      elevation: 4,
      child: const Icon(Icons.add),
    );
  }

  void _showTransactionTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: WiseSpendsColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: WiseSpendsColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Transaction',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            _buildTransactionTypeOption(
              context,
              type: TransactionType.income,
              title: 'Income',
              subtitle: 'Add money received',
              icon: Icons.arrow_downward_rounded,
              color: WiseSpendsColors.success,
            ),
            _buildTransactionTypeOption(
              context,
              type: TransactionType.expense,
              title: 'Expense',
              subtitle: 'Add money spent',
              icon: Icons.arrow_upward_rounded,
              color: WiseSpendsColors.secondary,
            ),
            _buildTransactionTypeOption(
              context,
              type: TransactionType.transfer,
              title: 'Transfer',
              subtitle: 'Move money between accounts',
              icon: Icons.swap_horiz_rounded,
              color: WiseSpendsColors.tertiary,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeOption(
    BuildContext context, {
    required TransactionType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        // Navigate to add transaction screen with type
        AppRouter.navigateTo(
          context,
          AppRoutes.addTransaction,
          arguments: AddTransactionArgs(preselectedType: type),
        );
      },
    );
  }
}
