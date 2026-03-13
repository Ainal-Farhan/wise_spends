// FIXED: Charts tab with proper types and real data
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_deposit_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_transaction_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_state.dart';
import 'package:wise_spends/shared/components/section_header.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';
import 'package:fl_chart/fl_chart.dart';

/// Charts tab widget - displays budget plan analytics charts
class BudgetPlanChartsTab extends StatelessWidget {
  final BudgetPlanDetailLoaded state;

  const BudgetPlanChartsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress chart
          SectionHeader(title: 'budget_plans.progress_chart'.tr),
          const SizedBox(height: AppSpacing.md),
          _ProgressChartCard(plan: state.plan),
          const SizedBox(height: AppSpacing.xxl),

          // Allocation chart
          SectionHeader(title: 'budget_plans.allocation_chart'.tr),
          const SizedBox(height: AppSpacing.md),
          _AllocationChartCard(
            totalDeposits: state.deposits.fold<double>(
              0,
              (s, d) => s + d.amount,
            ),
            totalTransactions: state.transactions.fold<double>(
              0,
              (s, t) => s + t.amount,
            ),
            totalMilestones: state.milestones.length,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Trend chart
          SectionHeader(title: 'budget_plans.trend_chart'.tr),
          const SizedBox(height: AppSpacing.md),
          _TrendChartCard(
            deposits: state.deposits,
            transactions: state.transactions,
          ),
        ],
      ),
    );
  }
}

/// Progress chart card widget
class _ProgressChartCard extends StatelessWidget {
  final BudgetPlanEntity plan;

  const _ProgressChartCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final progress = plan.progressPercentage.clamp(0.0, 1.0);
    final currentAmount = plan.currentAmount;
    final targetAmount = plan.targetAmount;
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text('budget_plans.progress_over_time'.tr, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: progress * 100,
                          title: '${(progress * 100).toStringAsFixed(1)}%',
                          color: WiseSpendsColors.primary,
                          radius: 80,
                          titleStyle: AppTextStyles.h3.copyWith(
                            color: WiseSpendsColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          value: (1 - progress) * 100,
                          title: '',
                          color: WiseSpendsColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          radius: 80,
                        ),
                      ],
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fmt.format(currentAmount),
                        style: AppTextStyles.amountMedium.copyWith(
                          color: WiseSpendsColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'budget_plans.of_target'.trWith({
                          'target': fmt.format(targetAmount),
                        }),
                        style: AppTextStyles.caption.copyWith(
                          color: WiseSpendsColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Allocation chart card widget
class _AllocationChartCard extends StatelessWidget {
  final double totalDeposits;
  final double totalTransactions;
  final int totalMilestones;

  const _AllocationChartCard({
    required this.totalDeposits,
    required this.totalTransactions,
    required this.totalMilestones,
  });

  @override
  Widget build(BuildContext context) {
    final double total =
        totalDeposits + totalTransactions + (totalMilestones * 100.0);
    final double depositsPct = total > 0 ? ((totalDeposits / total) * 100.0) : 0;
    final double transactionsPct = total > 0
        ? ((totalTransactions / total) * 100.0)
        : .0;
    final double milestonesPct = total > 0
        ? ((totalMilestones * 100.0) / total)
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'budget_plans.allocation_by_category'.tr,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(0)}%',
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
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'budget_plans.chart_deposits',
                            'budget_plans.chart_spendings',
                            'budget_plans.chart_milestones',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              titles[value.toInt()].tr,
                              style: AppTextStyles.captionSmall.copyWith(
                                color: WiseSpendsColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
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
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: WiseSpendsColors.divider,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: depositsPct,
                          color: WiseSpendsColors.success,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: transactionsPct,
                          color: WiseSpendsColors.error,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: milestonesPct,
                          color: WiseSpendsColors.primary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trend chart card widget
class _TrendChartCard extends StatelessWidget {
  final List<BudgetPlanDepositEntity> deposits;
  final List<BudgetPlanTransactionEntity> transactions;

  const _TrendChartCard({required this.deposits, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Group deposits by week (simplified - last 4 weeks)
    final depositByWeek = _groupByWeek(
      deposits.map((d) => d.depositDate).toList(),
    );
    final transactionByWeek = _groupByWeek(
      transactions.map((t) => t.transactionDate).toList(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text('budget_plans.spending_trend'.tr, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: WiseSpendsColors.divider,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'budget_plans.week_1',
                            'budget_plans.week_2',
                            'budget_plans.week_3',
                            'budget_plans.week_4',
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              titles[value.toInt()].tr,
                              style: AppTextStyles.captionSmall.copyWith(
                                color: WiseSpendsColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: depositByWeek.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: WiseSpendsColors.success,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: WiseSpendsColors.success.withValues(alpha: 0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: transactionByWeek.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: WiseSpendsColors.error,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: WiseSpendsColors.error.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        color: WiseSpendsColors.success,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'budget_plans.chart_deposits'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        color: WiseSpendsColors.error,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'budget_plans.chart_spendings'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Group dates by week (returns list of 4 values for last 4 weeks)
  List<double> _groupByWeek(List<DateTime> dates) {
    final weeks = List<double>.filled(4, 0);
    final now = DateTime.now();

    for (final date in dates) {
      final diff = now.difference(date).inDays;
      final weekIndex = (diff / 7).floor();
      if (weekIndex >= 0 && weekIndex < 4) {
        weeks[3 - weekIndex] += 1; // Count occurrences
      }
    }

    return weeks;
  }
}
