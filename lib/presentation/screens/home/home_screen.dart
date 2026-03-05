import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/presentation/widgets/components/transaction_card.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/router/route_arguments.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// Enhanced Home/Dashboard Screen
/// Features:
/// - Time-based greeting with emoji
/// - Hero balance card with gradient
/// - Income/Expense summary cards
/// - Quick actions row (Add Income, Expense, Transfer)
/// - Recent transactions list
/// - Pull-to-refresh
/// - Bottom navigation
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
    if (_isNavigating) return;

    setState(() => _selectedIndex = index);
    _isNavigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isNavigating = false;
        return;
      }

      switch (index) {
        case 0:
          _isNavigating = false;
          break;
        case 1:
          Navigator.pushNamed(context, AppRoutes.budgetList).then((_) {
            if (mounted) _isNavigating = false;
          });
          break;
        case 2:
          Navigator.pushNamed(context, AppRoutes.savings).then((_) {
            if (mounted) _isNavigating = false;
          });
          break;
        case 3:
          Navigator.pushNamed(context, AppRoutes.moneyStorage).then((_) {
            if (mounted) _isNavigating = false;
          });
          break;
        case 4:
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
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'WiseSpends',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textPrimary,
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
                    minWidth: AppTouchTarget.min,
                    minHeight: AppTouchTarget.min,
                  ),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance overview cards
                    _buildBalanceOverview(context),
                    const SizedBox(height: AppSpacing.xxl),

                    // Quick actions
                    _buildQuickActions(context),
                    const SizedBox(height: AppSpacing.xxl),

                    // Section header
                    SectionHeader(
                      title: 'Recent Transactions',
                      onSeeAll: () {
                        AppRouter.navigateTo(
                          context,
                          AppRoutes.transactionHistory,
                          arguments: const TransactionHistoryArgs(),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Recent transactions list
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is TransactionLoading) {
                          return const ShimmerTransactionList(itemCount: 5);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionTypeDialog(context),
        elevation: AppElevation.sm,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Money Storage',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning 👋';
    } else if (hour < 17) {
      return 'Good afternoon 👋';
    } else {
      return 'Good evening 👋';
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
              // Main balance card (Hero)
              AppCard.gradient(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      NumberFormat.currency(
                        symbol: 'RM ',
                        decimalDigits: 2,
                      ).format(totalBalance),
                      style: AppTextStyles.balanceDisplay,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Income and Expense cards
              Row(
                children: [
                  Expanded(
                    child: AppStatCard(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Income',
                      value: NumberFormat.currency(
                        symbol: 'RM ',
                        decimalDigits: 2,
                      ).format(totalIncome),
                      color: AppColors.income,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppStatCard(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expenses',
                      value: NumberFormat.currency(
                        symbol: 'RM ',
                        decimalDigits: 2,
                      ).format(totalExpenses),
                      color: AppColors.expense,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const Column(
          children: [
            ShimmerBalanceCard(isHero: true),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: ShimmerBalanceCard()),
                SizedBox(width: AppSpacing.md),
                Expanded(child: ShimmerBalanceCard()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionItem(
                context,
                icon: Icons.arrow_downward_rounded,
                label: 'Income',
                color: AppColors.income,
                onTap: () => _navigateToAddTransaction(TransactionType.income),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildQuickActionItem(
                context,
                icon: Icons.arrow_upward_rounded,
                label: 'Expense',
                color: AppColors.expense,
                onTap: () => _navigateToAddTransaction(TransactionType.expense),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildQuickActionItem(
                context,
                icon: Icons.swap_horiz_rounded,
                label: 'Transfer',
                color: AppColors.transfer,
                onTap: () =>
                    _navigateToAddTransaction(TransactionType.transfer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: AppTouchTarget.min,
              height: AppTouchTarget.min,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: AppIconSize.lg,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddTransaction(TransactionType type) {
    AppRouter.navigateTo(
      context,
      AppRoutes.addTransaction,
      arguments: AddTransactionArgs(preselectedType: type),
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
          const SizedBox(height: AppSpacing.sm),
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
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: AppIconSize.hero,
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Oops! Something went wrong',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: 'Retry',
            onPressed: () {
              context.read<TransactionBloc>().add(
                LoadRecentTransactionsEvent(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTransactionTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              'Add Transaction',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTransactionTypeOption(
              context,
              type: TransactionType.income,
              title: 'Income',
              subtitle: 'Add money received',
              icon: Icons.arrow_downward_rounded,
              color: AppColors.income,
            ),
            _buildTransactionTypeOption(
              context,
              type: TransactionType.expense,
              title: 'Expense',
              subtitle: 'Add money spent',
              icon: Icons.arrow_upward_rounded,
              color: AppColors.expense,
            ),
            _buildTransactionTypeOption(
              context,
              type: TransactionType.transfer,
              title: 'Transfer',
              subtitle: 'Move money between accounts',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.transfer,
            ),
            const SizedBox(height: AppSpacing.lg),
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
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
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
