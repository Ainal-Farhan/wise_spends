import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';
import 'package:wise_spends/domain/repositories/budget_repository.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_event.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_state.dart';
import 'package:wise_spends/presentation/widgets/components/empty_state_widget.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Budget List Screen
/// Features:
/// - Budget summary card at top
/// - Budget cards with progress indicators
/// - Color-coded progress (green/amber/red)
/// - Add budget FAB
/// - Pull-to-refresh
class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BudgetBloc(context.read<IBudgetRepository>())
            ..add(LoadBudgetsEvent()),
      child: const _BudgetListScreenContent(),
    );
  }
}

class _BudgetListScreenContent extends StatefulWidget {
  const _BudgetListScreenContent();

  @override
  State<_BudgetListScreenContent> createState() =>
      _BudgetListScreenContentState();
}

class _BudgetListScreenContentState extends State<_BudgetListScreenContent> {
  BudgetPeriod? _filterPeriod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<BudgetBloc>().add(RefreshBudgetsEvent());
        },
        child: CustomScrollView(
          slivers: [
            // Summary card
            SliverToBoxAdapter(child: _buildSummaryCard(context)),

            // Budget list
            SliverPadding(
              padding: const EdgeInsets.all(UIConstants.spacingLarge),
              sliver: BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  if (state is BudgetLoading) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const BudgetCardShimmer(),
                        childCount: 3,
                      ),
                    );
                  } else if (state is BudgetsLoaded) {
                    if (state.budgets.isEmpty) {
                      return SliverToBoxAdapter(
                        child: NoBudgetsEmptyState(
                          onAddBudget: () => _navigateToCreateBudget(context),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final budget = state.budgets[index];
                        return _buildBudgetCard(context, budget);
                      }, childCount: state.budgets.length),
                    );
                  } else if (state is BudgetEmpty) {
                    return SliverToBoxAdapter(
                      child: NoBudgetsEmptyState(
                        onAddBudget: () => _navigateToCreateBudget(context),
                      ),
                    );
                  } else if (state is BudgetError) {
                    return SliverToBoxAdapter(
                      child: ErrorStateWidget(
                        message: state.message,
                        onAction: () {
                          context.read<BudgetBloc>().add(LoadBudgetsEvent());
                        },
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
        onPressed: () => _navigateToCreateBudget(context),
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state is BudgetsLoaded) {
          final totalBudgets = state.budgets.length;
          final onTrack = state.onTrackCount;
          final percentage = totalBudgets > 0
              ? (onTrack / totalBudgets * 100).toInt()
              : 0;

          return Container(
            margin: const EdgeInsets.all(UIConstants.spacingLarge),
            padding: const EdgeInsets.all(UIConstants.spacingXXL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  WiseSpendsColors.tertiary,
                  WiseSpendsColors.tertiaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: WiseSpendsColors.tertiary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: UIConstants.spacingMedium),
                Text(
                  '$onTrack of $totalBudgets budgets on track',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingXS),
                Text(
                  '$percentage% success rate',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          );
        }
        return const BudgetCardShimmer();
      },
    );
  }

  Widget _buildBudgetCard(BuildContext context, dynamic budget) {
    // Calculate progress percentage
    final spentAmount = budget.spentAmount as double? ?? 0.0;
    final budgetAmount = budget.amount as double? ?? 1.0;
    final progress = spentAmount / budgetAmount;
    final progressColor = WiseSpendsColors.getBudgetProgressColor(progress);

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMedium),
      elevation: UIConstants.elevationNone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        side: const BorderSide(color: WiseSpendsColors.divider),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to budget detail
          // AppRouter.navigateTo(
          //   context,
          //   AppRoutes.budgetDetail,
          //   arguments: BudgetDetailArgs(budget.id),
          // );
        },
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category icon
                  Container(
                    width: UIConstants.touchTargetMin,
                    height: UIConstants.touchTargetMin,
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        UIConstants.radiusSmall,
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: progressColor,
                      size: UIConstants.iconLarge,
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name.toString(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${budget.categoryName ?? 'Category'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: WiseSpendsColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // More options button
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showBudgetOptions(context, budget);
                    },
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: progressColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: UIConstants.spacingSmall),
              // Amount text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: 'RM ',
                      decimalDigits: 2,
                    ).format(spentAmount),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    'of ${NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(budgetAmount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WiseSpendsColors.textSecondary,
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

  void _showBudgetOptions(BuildContext context, dynamic budget) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Budget'),
              onTap: () {
                Navigator.pop(context);
                _showEditBudgetDialog(context, budget);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: WiseSpendsColors.secondary,
              ),
              title: const Text(
                'Delete Budget',
                style: TextStyle(color: WiseSpendsColors.secondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteBudget(context, budget);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, dynamic budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: Text(
          'Are you sure you want to delete "${budget.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetBloc>().add(
                DeleteBudgetEvent(budget.id.toString()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WiseSpendsColors.secondary,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Budgets'),
        content: RadioGroup<BudgetPeriod?>(
          groupValue: _filterPeriod,
          onChanged: (value) {
            setState(() => _filterPeriod = value);
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<BudgetPeriod?>(
                title: const Text('All Periods'),
                value: null,
              ),
              RadioListTile<BudgetPeriod?>(
                title: const Text('Daily'),
                value: BudgetPeriod.daily,
              ),
              RadioListTile<BudgetPeriod?>(
                title: const Text('Weekly'),
                value: BudgetPeriod.weekly,
              ),
              RadioListTile<BudgetPeriod?>(
                title: const Text('Monthly'),
                value: BudgetPeriod.monthly,
              ),
              RadioListTile<BudgetPeriod?>(
                title: const Text('Yearly'),
                value: BudgetPeriod.yearly,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _filterPeriod = null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, dynamic budget) {
    // Placeholder for edit budget dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit budget feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToCreateBudget(BuildContext context) {
    // Navigate to create budget screen when ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create budget feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
