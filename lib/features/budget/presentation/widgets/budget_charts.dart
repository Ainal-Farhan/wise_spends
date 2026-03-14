import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_analytics.dart';

/// Monthly Contributions Bar Chart
/// Shows deposits vs spending over time
class BudgetMonthlyContributionsChart extends StatelessWidget {
  final List<MonthlyContribution> data;
  final double requiredMonthlySaving;

  const BudgetMonthlyContributionsChart({
    super.key,
    required this.data,
    this.requiredMonthlySaving = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _calculateMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final color = rodIndex == 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary;
                  return BarTooltipItem(
                    'RM ${rod.toY.toStringAsFixed(0)}',
                    TextStyle(color: color, fontWeight: FontWeight.bold),
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
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[value.toInt()].monthName,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
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
              horizontalInterval: _calculateMaxY() / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).colorScheme.outline,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: data
                .map(
                  (month) => BarChartGroupData(
                    x: data.indexOf(month),
                    barRods: [
                      BarChartRodData(
                        toY: month.deposits,
                        color: Theme.of(context).colorScheme.primary,
                        width: 10,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: month.spending,
                        color: Theme.of(context).colorScheme.secondary,
                        width: 10,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (data.isEmpty) return 100;
    // Find the maximum value across all deposits and spending
    double maxValue = 0;
    for (final month in data) {
      if (month.deposits > maxValue) maxValue = month.deposits;
      if (month.spending > maxValue) maxValue = month.spending;
    }
    // Handle potential infinity or very large numbers
    if (maxValue.isInfinite || maxValue > 1e15) {
      return 1e15; // Cap at a reasonable maximum
    }
    // Round up to nearest 100 and add padding
    final rounded = (maxValue / 100).ceil() * 100.0;
    final withPadding = rounded + 100.0;
    // Final overflow check
    return withPadding.isInfinite || withPadding > 1e15
        ? 1e15
        : withPadding.toDouble();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress History Line Chart
/// Shows cumulative savings over time
class BudgetProgressChart extends StatelessWidget {
  final List<PlanProgressSnapshot> snapshots;
  final double targetAmount;

  const BudgetProgressChart({
    super.key,
    required this.snapshots,
    required this.targetAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return _buildEmptyState(context);
    }

    final spots = snapshots
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
        .toList();

    final requiredPaceSpots = [
      FlSpot(0, 0),
      FlSpot(snapshots.length.toDouble() - 1, targetAmount),
    ];

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      'RM ${spot.y.toStringAsFixed(0)}',
                      TextStyle(
                        color: spot.barIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < snapshots.length) {
                      final date = snapshots[value.toInt()].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
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
              horizontalInterval: targetAmount / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).colorScheme.outline,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              // Actual savings line
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              // Required pace line
              LineChartBarData(
                spots: requiredPaceSpots,
                isCurved: false,
                color: Colors.grey,
                barWidth: 2,
                dashArray: [5, 5],
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No progress data',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Spending Breakdown Donut Chart
/// Shows expense distribution by category
class BudgetSpendingDonutChart extends StatelessWidget {
  final List<SpendingByCategory> data;
  final double totalSpent;

  const BudgetSpendingDonutChart({
    super.key,
    required this.data,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    final colors = [
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.outline,
    ];

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 60,
            sections: data.asMap().entries.map((e) {
              final index = e.key;
              final category = e.value;
              return PieChartSectionData(
                value: category.amount,
                title: '${category.percentage.toStringAsFixed(0)}%',
                color: colors[index % colors.length],
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No spending data',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chart Legend Widget
class BudgetChartLegend extends StatelessWidget {
  final List<SpendingByCategory> data;

  const BudgetChartLegend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.outline,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.asMap().entries.map((e) {
        final index = e.key;
        final category = e.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(category.category, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
