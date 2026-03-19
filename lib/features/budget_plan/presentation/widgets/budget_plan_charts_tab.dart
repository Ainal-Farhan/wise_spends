import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_analytics_bloc.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_analytics_event.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_analytics_state.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/i_budget_plan_repository.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_analytics.dart'
    show MonthlyContribution, PlanProgressSnapshot, SpendingByCategory;
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';

// ─── Constants ─────────────────────────────────────────────────────────────

const double _kChartHeight = 220.0;
const double _kDonutRadius = 52.0;
const double _kCenterRadius = 58.0;

// ─── Root widget ───────────────────────────────────────────────────────────

/// Charts tab — provisions its own [BudgetAnalyticsBloc] via [BlocProvider].
class BudgetPlanChartsTab extends StatelessWidget {
  final String planUuid;
  final BudgetPlanEntity plan;

  final IBudgetPlanRepository repository =
      SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository();

  BudgetPlanChartsTab({super.key, required this.planUuid, required this.plan});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BudgetAnalyticsBloc>(
      // Plain constructor injection — no context.read inside create.
      create: (_) => BudgetAnalyticsBloc(repository),
      child: _BudgetPlanChartsTabBody(planUuid: planUuid, plan: plan),
    );
  }
}

// ─── Body (StatefulWidget — safe to call context.read here) ───────────────

/// Internal body widget. By the time this widget's [initState] runs, the
/// [BlocProvider<BudgetAnalyticsBloc>] from [BudgetPlanChartsTab] is already
/// in the tree, so `context.read<BudgetAnalyticsBloc>()` succeeds.
class _BudgetPlanChartsTabBody extends StatefulWidget {
  final String planUuid;
  final BudgetPlanEntity plan;

  const _BudgetPlanChartsTabBody({required this.planUuid, required this.plan});

  @override
  State<_BudgetPlanChartsTabBody> createState() =>
      _BudgetPlanChartsTabBodyState();
}

class _BudgetPlanChartsTabBodyState extends State<_BudgetPlanChartsTabBody> {
  @override
  void initState() {
    super.initState();
    // Safe: context is a descendant of BlocProvider<BudgetAnalyticsBloc>.
    context.read<BudgetAnalyticsBloc>().add(LoadPlanAnalytics(widget.planUuid));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetAnalyticsBloc, BudgetAnalyticsState>(
      builder: (context, state) {
        return switch (state) {
          BudgetAnalyticsInitial() ||
          BudgetAnalyticsLoading() => _buildLoadingShimmer(context),
          BudgetAnalyticsLoaded() => _buildLoaded(context, state),
          BudgetAnalyticsError() => _buildError(context, state.message),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoadingShimmer(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _ShimmerCard(height: 300 + i * 20.0),
          ),
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'budget_plans.analytics_error'.tr,
              style: AppTextStyles.h3.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonal(
              onPressed: () => context.read<BudgetAnalyticsBloc>().add(
                LoadPlanAnalytics(widget.planUuid),
              ),
              child: Text('common.retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loaded ─────────────────────────────────────────────────────────────────

  Widget _buildLoaded(BuildContext context, BudgetAnalyticsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Period selector ───────────────────────────────────────────────
          _PeriodSelector(current: state.period),
          const SizedBox(height: AppSpacing.lg),

          // ── Stat summary strip ────────────────────────────────────────────
          _StatSummaryStrip(state: state),
          const SizedBox(height: AppSpacing.lg),

          // ── Progress donut ────────────────────────────────────────────────
          _ProgressChartCard(plan: widget.plan),
          const SizedBox(height: AppSpacing.lg),

          // ── Contribution & spending bar chart ─────────────────────────────
          _ContributionChartCard(
            contributions: state.monthlyContributions,
            period: state.period,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Spending-by-category donut ────────────────────────────────────
          _SpendingByCategoryCard(spendingByCategory: state.spendingByCategory),
          const SizedBox(height: AppSpacing.lg),

          // ── Progress history line chart ───────────────────────────────────
          _ProgressHistoryCard(
            history: state.progressHistory,
            targetAmount: widget.plan.targetAmount,
          ),
        ],
      ),
    );
  }
}

// ─── Period selector ───────────────────────────────────────────────────────

/// Horizontal scrollable chip row for picking the analytics window.
class _PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod current;

  const _PeriodSelector({required this.current});

  static const _periods = [
    (AnalyticsPeriod.week, 'budget_plans.period_week'),
    (AnalyticsPeriod.month, 'budget_plans.period_month'),
    (AnalyticsPeriod.quarter, 'budget_plans.period_quarter'),
    (AnalyticsPeriod.year, 'budget_plans.period_year'),
    (AnalyticsPeriod.all, 'budget_plans.period_all'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((entry) {
          final (period, labelKey) = entry;
          final isSelected = period == current;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: ChoiceChip(
              label: Text(labelKey.tr),
              selected: isSelected,
              onSelected: (_) {
                if (!isSelected) {
                  context.read<BudgetAnalyticsBloc>().add(ChangePeriod(period));
                }
              },
              labelStyle: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Stat summary strip ────────────────────────────────────────────────────

/// Three key metrics in a horizontal row of small stat tiles.
///
/// Shows: avg monthly deposit | avg monthly spending | projected completion.
class _StatSummaryStrip extends StatelessWidget {
  final BudgetAnalyticsLoaded state;

  const _StatSummaryStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.compactCurrency(symbol: 'RM', decimalDigits: 0);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.arrow_downward_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            label: 'budget_plans.avg_deposit'.tr,
            value: fmt.format(state.averageMonthlyDeposit),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.arrow_upward_rounded,
            iconColor: Theme.of(context).colorScheme.error,
            label: 'budget_plans.avg_spending'.tr,
            value: fmt.format(state.averageMonthlySpending),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.flag_rounded,
            iconColor: Theme.of(context).colorScheme.tertiary,
            label: 'budget_plans.projected_completion'.tr,
            value: state.projectedCompletionLabel,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Shared card shell ─────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;
  final Widget child;

  const _ChartCard({
    required this.title,
    this.subtitle,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: accentColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend item ───────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Empty chart placeholder ───────────────────────────────────────────────

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: _kChartHeight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shimmer card ──────────────────────────────────────────────────────────

/// A pulsing placeholder shown during [BudgetAnalyticsLoading].
class _ShimmerCard extends StatefulWidget {
  final double height;

  const _ShimmerCard({required this.height});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4 + _anim.value * 0.4,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ─── 1. Progress donut ─────────────────────────────────────────────────────

/// Donut showing current progress vs target. Reads from [BudgetPlanEntity]
/// since target/current are always up to date on the plan itself.
class _ProgressChartCard extends StatelessWidget {
  final BudgetPlanEntity plan;

  const _ProgressChartCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = plan.progressPercentage.clamp(0.0, 1.0);
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);
    final pctLabel = '${(progress * 100).toStringAsFixed(1)}%';
    final filledColor = colorScheme.primary;
    final remainColor = colorScheme.surfaceContainerHighest;

    return _ChartCard(
      title: 'budget_plans.progress_chart'.tr,
      subtitle: 'budget_plans.progress_over_time'.tr,
      accentColor: filledColor,
      child: Column(
        children: [
          SizedBox(
            height: _kChartHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: progress * 100,
                        title: '',
                        color: filledColor,
                        radius: _kDonutRadius,
                      ),
                      PieChartSectionData(
                        value: (1 - progress) * 100,
                        title: '',
                        color: remainColor,
                        radius: _kDonutRadius,
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: _kCenterRadius,
                  ),
                ),
                SizedBox(
                  width: _kCenterRadius * 1.7,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          pctLabel,
                          style: AppTextStyles.h2.copyWith(
                            color: filledColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          fmt.format(plan.currentAmount),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '/ ${fmt.format(plan.targetAmount)}',
                          style: AppTextStyles.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              _LegendItem(
                color: filledColor,
                label: 'budget_plans.chart_achieved'.tr,
              ),
              _LegendItem(
                color: remainColor,
                label: 'budget_plans.chart_remaining'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 2. Monthly contributions bar chart ────────────────────────────────────

/// Grouped bar chart (deposits vs spending) per month from the analytics BLoC.
///
/// Uses [MonthlyContribution] records directly — no manual grouping needed
/// since the BLoC already filtered and windowed the data for the chosen period.
class _ContributionChartCard extends StatelessWidget {
  final List<MonthlyContribution> contributions;
  final AnalyticsPeriod period;

  const _ContributionChartCard({
    required this.contributions,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final depositColor = colorScheme.primary;
    final spendingColor = colorScheme.error;

    if (contributions.isEmpty) {
      return _ChartCard(
        title: 'budget_plans.allocation_chart'.tr,
        accentColor: colorScheme.tertiary,
        child: _EmptyChart(message: 'budget_plans.no_allocation_data'.tr),
      );
    }

    // Use the built-in monthName getter from MonthlyContribution.
    final labels = contributions.map((c) => c.monthName).toList();

    final maxVal = contributions.fold<double>(0, (m, c) {
      final v = c.deposits > c.spending ? c.deposits : c.spending;
      return v > m ? v : m;
    });

    return _ChartCard(
      title: 'budget_plans.allocation_chart'.tr,
      subtitle: 'budget_plans.allocation_by_category'.tr,
      accentColor: colorScheme.tertiary,
      child: Column(
        children: [
          SizedBox(
            height: _kChartHeight,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.25,
                groupsSpace: 12,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isDeposit = rodIndex == 0;
                      final label = isDeposit
                          ? 'budget_plans.chart_deposits'.tr
                          : 'budget_plans.chart_spendings'.tr;
                      return BarTooltipItem(
                        '$label\nRM ${rod.toY.toStringAsFixed(0)}',
                        AppTextStyles.caption.copyWith(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[idx],
                            style: AppTextStyles.captionSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value != meta.min && value != meta.max) {
                          return const SizedBox.shrink();
                        }
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            NumberFormat.compactCurrency(
                              symbol: 'RM',
                              decimalDigits: 0,
                            ).format(value),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: contributions.asMap().entries.map((e) {
                  final idx = e.key;
                  final c = e.value;
                  return BarChartGroupData(
                    x: idx,
                    groupVertically: false,
                    barRods: [
                      BarChartRodData(
                        toY: c.deposits,
                        color: depositColor,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal * 1.25,
                          color: depositColor.withValues(alpha: 0.06),
                        ),
                      ),
                      BarChartRodData(
                        toY: c.spending,
                        color: spendingColor,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxVal * 1.25,
                          color: spendingColor.withValues(alpha: 0.06),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              _LegendItem(
                color: depositColor,
                label: 'budget_plans.chart_deposits'.tr,
              ),
              _LegendItem(
                color: spendingColor,
                label: 'budget_plans.chart_spendings'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 3. Spending by category ───────────────────────────────────────────────

/// Horizontal bar chart showing spending broken down by category.
///
/// Uses [SpendingByCategory] records — `.percentage` is pre-computed by the
/// repository so we use it directly instead of dividing by the max value.
/// The optional `.iconCode` is rendered as a leading icon when present.
class _SpendingByCategoryCard extends StatelessWidget {
  final List<SpendingByCategory> spendingByCategory;

  const _SpendingByCategoryCard({required this.spendingByCategory});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (spendingByCategory.isEmpty) {
      return _ChartCard(
        title: 'budget_plans.spending_by_category'.tr,
        accentColor: colorScheme.secondary,
        child: _EmptyChart(message: 'budget_plans.no_category_data'.tr),
      );
    }

    // Sort descending by amount and take top 6 for mobile readability.
    final top = ([
      ...spendingByCategory,
    ]..sort((a, b) => b.amount.compareTo(a.amount))).take(6).toList();

    final fmt = NumberFormat.compactCurrency(symbol: 'RM', decimalDigits: 0);

    final palette = [
      colorScheme.primary,
      colorScheme.error,
      colorScheme.tertiary,
      colorScheme.secondary,
      colorScheme.primaryContainer,
      colorScheme.tertiaryContainer,
    ];

    return _ChartCard(
      title: 'budget_plans.spending_by_category'.tr,
      subtitle: 'budget_plans.top_categories'.tr,
      accentColor: colorScheme.secondary,
      child: Column(
        children: top.asMap().entries.map((e) {
          final idx = e.key;
          final cat = e.value;
          // Use the pre-computed percentage (0–100) from the entity.
          final barValue = (cat.percentage / 100).clamp(0.0, 1.0);
          final color = palette[idx % palette.length];

          // Optional icon from iconCode
          IconData? iconData;
          if (cat.iconCode != null) {
            final code = int.tryParse(cat.iconCode!);
            if (code != null) {
              iconData = IconData(code, fontFamily: 'MaterialIcons');
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                // Icon or coloured dot
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: iconData != null
                        ? Icon(iconData, size: 14, color: color)
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Category name — fixed width prevents layout jitter
                SizedBox(
                  width: 72,
                  child: Text(
                    cat.category,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Bar — uses pre-computed percentage directly
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barValue,
                      minHeight: 12,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Percentage label
                SizedBox(
                  width: 36,
                  child: Text(
                    '${cat.percentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Amount
                SizedBox(
                  width: 52,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      fmt.format(cat.amount),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── 4. Progress history line chart ───────────────────────────────────────

/// Line chart showing how the saved amount has grown over time.
///
/// Uses [PlanProgressSnapshot] records — each has [date], [amount],
/// [targetAmount], and [progressPercentage].
/// The target amount is drawn as a dashed reference line.
class _ProgressHistoryCard extends StatelessWidget {
  final List<PlanProgressSnapshot> history;
  final double targetAmount;

  const _ProgressHistoryCard({
    required this.history,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineColor = colorScheme.primary;
    final targetColor = colorScheme.tertiary;

    if (history.isEmpty) {
      return _ChartCard(
        title: 'budget_plans.trend_chart'.tr,
        accentColor: lineColor,
        child: _EmptyChart(message: 'budget_plans.no_trend_data'.tr),
      );
    }

    // Sort chronologically
    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    final maxVal = sorted.fold<double>(
      targetAmount,
      (m, s) => s.amount > m ? s.amount : m,
    );

    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    // X-axis labels — show first, middle, last to avoid crowding
    final labelIndices = {0, (sorted.length / 2).floor(), sorted.length - 1};

    return _ChartCard(
      title: 'budget_plans.trend_chart'.tr,
      subtitle: 'budget_plans.spending_trend'.tr,
      accentColor: lineColor,
      child: Column(
        children: [
          SizedBox(
            height: _kChartHeight,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxVal * 1.15,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 ||
                            idx >= sorted.length ||
                            !labelIndices.contains(idx)) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('d MMM').format(sorted[idx].date),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) {
                        if (value != meta.min && value != meta.max) {
                          return const SizedBox.shrink();
                        }
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            NumberFormat.compactCurrency(
                              symbol: 'RM',
                              decimalDigits: 0,
                            ).format(value),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                // Dashed target reference line
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: targetAmount,
                      color: targetColor.withValues(alpha: 0.7),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        style: AppTextStyles.captionSmall.copyWith(
                          color: targetColor,
                          fontWeight: FontWeight.w600,
                        ),
                        labelResolver: (_) => 'budget_plans.chart_target'.tr,
                      ),
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) {
                      return LineTooltipItem(
                        'RM ${spot.y.toStringAsFixed(0)}',
                        AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: lineColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, i) => FlDotCirclePainter(
                        radius: 3.5,
                        color: lineColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: 0.18),
                          lineColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              _LegendItem(
                color: lineColor,
                label: 'budget_plans.chart_progress'.tr,
              ),
              _LegendItem(
                color: targetColor,
                label: 'budget_plans.chart_target'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
