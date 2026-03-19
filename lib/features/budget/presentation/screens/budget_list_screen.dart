// FIXED: Reduced from 1,752 lines by extracting widgets to separate files
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget/data/repositories/i_budget_repository.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_event.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_state.dart';
import 'package:wise_spends/features/budget/presentation/screens/create_budget_sheet.dart';
import 'package:wise_spends/features/budget/presentation/widgets/budget_header_card.dart';
import 'package:wise_spends/features/budget/presentation/widgets/budget_filter_chip_row.dart';
import 'package:wise_spends/features/budget/presentation/widgets/budget_card.dart';
import 'package:wise_spends/features/category/data/repositories/impl/category_repository.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BudgetBloc(context.read<IBudgetRepository>())
            ..add(LoadBudgetsEvent())
            ..add(const SyncAllBudgetsSpentAmountEvent()),
        ),
        BlocProvider(create: (_) => CategoryBloc(CategoryRepository())),
      ],
      child: const _BudgetListScreenContent(),
    );
  }
}

class _BudgetListScreenContent extends StatelessWidget {
  const _BudgetListScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('budgets.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'general.filter'.tr,
          ),
        ],
      ),
      drawer: NavigationSidebar(),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<BudgetBloc>().add(RefreshBudgetsEvent()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      0,
                    ),
                    child: BudgetHeaderCard(state: state),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: BudgetFilterChipRow(
                      state: state,
                      onFilterSelected: (period) {
                        context.read<BudgetBloc>().add(
                          FilterBudgetsByPeriodEvent(period),
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: _buildListSliver(context, state),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBudgetDialog(context),
        elevation: AppElevation.sm,
        tooltip: 'budgets.create'.tr,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListSliver(BuildContext context, BudgetState state) {
    if (state is BudgetLoading || state is BudgetInitial) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, _) => const ShimmerBudgetCard(),
          childCount: 3,
        ),
      );
    }

    if (state is BudgetsLoaded) {
      if (state.budgets.isEmpty) {
        return SliverToBoxAdapter(
          child: NoBudgetsEmptyState(
            onAddBudget: () => _showCreateBudgetDialog(context),
          ),
        );
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => BudgetCard(
            budget: state.budgets[i],
            categoryName: state.categoryNames[state.budgets[i].categoryId],
          ),
          childCount: state.budgets.length,
        ),
      );
    }

    if (state is BudgetEmpty) {
      return SliverToBoxAdapter(
        child: NoBudgetsEmptyState(
          onAddBudget: () => _showCreateBudgetDialog(context),
        ),
      );
    }

    if (state is BudgetError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton.primary(
                  label: 'general.retry'.tr,
                  onPressed: () {
                    context.read<BudgetBloc>().add(LoadBudgetsEvent());
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetBloc>(),
        child: const BudgetFilterBottomSheet(),
      ),
    );
  }

  void _showCreateBudgetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<BudgetBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: const CreateBudgetSheet(),
      ),
    );
  }
}

/// Budget filter bottom sheet - filter by period
class BudgetFilterBottomSheet extends StatelessWidget {
  const BudgetFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        final currentPeriod = state is BudgetsLoaded
            ? state.filterPeriod
            : null;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
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
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('budgets.filter'.tr, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.lg),
              // Filter options
              _FilterChip(
                label: 'budgets.period_all'.tr,
                selected: currentPeriod == null,
                onTap: () => _applyFilter(context, null),
              ),
              _FilterChip(
                label: 'budgets.period_daily'.tr,
                selected: currentPeriod == BudgetPeriod.daily,
                onTap: () => _applyFilter(context, BudgetPeriod.daily),
              ),
              _FilterChip(
                label: 'budgets.period_weekly'.tr,
                selected: currentPeriod == BudgetPeriod.weekly,
                onTap: () => _applyFilter(context, BudgetPeriod.weekly),
              ),
              _FilterChip(
                label: 'budgets.period_monthly'.tr,
                selected: currentPeriod == BudgetPeriod.monthly,
                onTap: () => _applyFilter(context, BudgetPeriod.monthly),
              ),
              _FilterChip(
                label: 'budgets.period_yearly'.tr,
                selected: currentPeriod == BudgetPeriod.yearly,
                onTap: () => _applyFilter(context, BudgetPeriod.yearly),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: AppButton.secondary(
                  label: 'general.close'.tr,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilter(BuildContext context, BudgetPeriod? period) {
    context.read<BudgetBloc>().add(FilterBudgetsByPeriodEvent(period));
    Navigator.pop(context);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
