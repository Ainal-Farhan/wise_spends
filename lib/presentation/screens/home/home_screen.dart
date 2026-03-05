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

/// Enhanced Home/Dashboard Screen
/// Features:
/// - Time-based greeting
/// - Balance overview cards (Total, Income, Expenses)
/// - Recent transactions list with grouped dates
/// - Quick action FAB with speed dial
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
  int _selectedIndex = 0;
  bool _isNavigating = false;

  void _onItemTapped(int index) {
    if (_isNavigating) return; // Prevent multiple taps
    
    setState(() {
      _selectedIndex = index;
    });
    
    _isNavigating = true;
    
    // Use WidgetsBinding to ensure navigation happens after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isNavigating = false;
        return;
      }
      
      switch (index) {
        case 0: // Home
          // Already on home
          _isNavigating = false;
          break;
        case 1: // Budget Plans
          Navigator.pushNamed(context, AppRoutes.budgetList).then((_) {
            if (mounted) _isNavigating = false;
          });
          break;
        case 2: // Savings
          Navigator.pushNamed(context, AppRoutes.savings).then((_) {
            if (mounted) _isNavigating = false;
          });
          break;
        case 3: // Money Storage
          Navigator.pushNamed(context, AppRoutes.moneyStorage).then((_) {
            if (mounted) _isNavigating = false;
          });
          break;
        case 4: // Settings
          Navigator.pushNamed(context, AppRoutes.settings).then((_) {
            if (mounted) _isNavigating = false;
          });
          break;
      }
    });
  }

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
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                  tooltip: 'Notifications',
                  constraints: const BoxConstraints(
                    minWidth: UIConstants.touchTargetMin,
                    minHeight: UIConstants.touchTargetMin,
                  ),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance overview cards
                    _buildBalanceOverview(context),
                    const SizedBox(height: UIConstants.spacingXXL),

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
                    const SizedBox(height: UIConstants.spacingSmall),

                    // Recent transactions list
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is TransactionLoading) {
                          return const TransactionListShimmer(itemCount: 5);
                        } else if (state is RecentTransactionsLoaded) {
                          if (state.recentTransactions.isEmpty) {
                            return NoTransactionsEmptyState(
                              onAddTransaction: () =>
                                  _showTransactionTypeDialog(context),
                            );
                          }
                          return _buildTransactionList(
                            context,
                            state.recentTransactions,
                          );
                        } else if (state is TransactionError) {
                          return _buildErrorState(context, state.message);
                        } else if (state is TransactionEmpty) {
                          return NoTransactionsEmptyState(
                            onAddTransaction: () =>
                                _showTransactionTypeDialog(context),
                          );
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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Savings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Money Storage',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: WiseSpendsColors.primary,
        unselectedItemColor: WiseSpendsColors.textSecondary,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
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
        if (state is TransactionLoaded || state is RecentTransactionsLoaded) {
          final totalIncome = state is TransactionLoaded
              ? state.totalIncome
              : (state as RecentTransactionsLoaded).totalIncome;
          final totalExpenses = state is TransactionLoaded
              ? state.totalExpenses
              : (state as RecentTransactionsLoaded).totalExpenses;
          final totalBalance = totalIncome - totalExpenses;

          return Column(
            children: [
              // Main balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(UIConstants.spacingXXL),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      WiseSpendsColors.primary,
                      WiseSpendsColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
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
                    const SizedBox(height: UIConstants.spacingSmall),
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
              const SizedBox(height: UIConstants.spacingMedium),

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
                  const SizedBox(width: UIConstants.spacingMedium),
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
            SizedBox(height: UIConstants.spacingMedium),
            Row(
              children: [
                Expanded(child: BalanceCardShimmer()),
                SizedBox(width: UIConstants.spacingMedium),
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
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
        border: Border.all(color: WiseSpendsColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: UIConstants.touchTargetMin,
                height: UIConstants.touchTargetMin,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                ),
                child: Icon(icon, color: color, size: UIConstants.iconLarge),
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingMedium),
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
      separatorBuilder: (context, index) =>
          const SizedBox(height: UIConstants.spacingSmall),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCard(
          title: transaction.title,
          amount: transaction.amount,
          type: transaction.type,
          icon: _getCategoryIcon(transaction.categoryId),
          date: transaction.date,
          note: transaction.note,
          onTap: () {
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

  IconData _getCategoryIcon(String? categoryId) {
    if (categoryId == null) return Icons.category_rounded;
    return CategoryIconMapper.getIconForCategory(categoryId);
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.spacingXXXL),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: WiseSpendsColors.secondary,
          ),
          const SizedBox(height: UIConstants.spacingLarge),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingLarge),
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(UIConstants.radiusXXLarge),
          ),
        ),
        padding: const EdgeInsets.all(UIConstants.spacingXXL),
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
            const SizedBox(height: UIConstants.spacingXXL),
            Text(
              'Add Transaction',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: UIConstants.spacingLarge),
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
            const SizedBox(height: UIConstants.spacingLarge),
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
      minLeadingWidth: UIConstants.touchTargetMin,
      leading: Container(
        width: UIConstants.touchTargetMin,
        height: UIConstants.touchTargetMin,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
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
        AppRouter.navigateTo(
          context,
          AppRoutes.addTransaction,
          arguments: AddTransactionArgs(preselectedType: type),
        );
      },
    );
  }
}
