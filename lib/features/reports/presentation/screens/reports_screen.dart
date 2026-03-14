import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wise_spends/features/reports/data/services/reports_export_service.dart';

/// Reports/Analytics Screen
/// Features:
/// - Period selector (Week/Month/Year)
/// - Bar chart for income vs expenses over time
/// - Donut chart for expense breakdown by category
/// - Summary cards with vs last period indicators
/// - Export to CSV
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reports.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () async {
              try {
                // Export report to CSV
                final exportService = ReportsExportService();
                final filePath = await exportService.exportReportToCsv(
                  period: _selectedPeriod.name,
                  totalIncome: 5420.00,
                  totalExpenses: 3250.50,
                  totalBalance: 2169.50,
                  categoryBreakdown: {
                    'Food': 1250.00,
                    'Transport': 890.50,
                    'Shopping': 715.25,
                    'Bills': 536.75,
                    'Other': 178.00,
                  },
                );
                await exportService.shareExport(filePath);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('reports.export_success'.tr),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('reports.export_failed'.trWith({'error': e.toString()})),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            tooltip: 'Export',
            constraints: const BoxConstraints(
              minWidth: AppTouchTarget.min,
              minHeight: AppTouchTarget.min,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(),
            const SizedBox(height: AppSpacing.xxl),

            // Summary cards
            _buildSummaryCards(),
            const SizedBox(height: AppSpacing.xxl),

            // Income vs Expenses bar chart
            SectionHeader(
              title: 'Income vs Expenses',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBarChart(),
            const SizedBox(height: AppSpacing.xxl),

            // Expense breakdown donut chart
            SectionHeader(
              title: 'Expense Breakdown',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDonutChart(),
            const SizedBox(height: AppSpacing.xxl),

            // Category-wise breakdown
            SectionHeader(
              title: 'By Category',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryBreakdown(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodOption(
              period: ReportPeriod.week,
              label: 'Week',
            ),
          ),
          Expanded(
            child: _buildPeriodOption(
              period: ReportPeriod.month,
              label: 'Month',
            ),
          ),
          Expanded(
            child: _buildPeriodOption(
              period: ReportPeriod.year,
              label: 'Year',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodOption({
    required ReportPeriod period,
    required String label,
  }) {
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                icon: Icons.arrow_downward_rounded,
                label: 'Income',
                value: NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(5420.00),
                trend: '+12.5%',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppStatCard(
                icon: Icons.arrow_upward_rounded,
                label: 'Expenses',
                value: NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(3250.50),
                trend: '-8.2%',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                icon: Icons.savings_outlined,
                label: 'Savings',
                value: NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(2169.50),
                trend: '+25.3%',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppStatCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Balance',
                value: NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(8750.25),
                trend: '+5.7%',
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10000,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(rod.toY),
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  const labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[value.toInt()],
                        style: AppTextStyles.caption,
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
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(toY: 5000, color: Theme.of(context).colorScheme.primary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                BarChartRodData(toY: 3000, color: Theme.of(context).colorScheme.secondary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: 6000, color: Theme.of(context).colorScheme.primary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                BarChartRodData(toY: 4000, color: Theme.of(context).colorScheme.secondary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: 4500, color: Theme.of(context).colorScheme.primary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                BarChartRodData(toY: 3500, color: Theme.of(context).colorScheme.secondary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(toY: 7000, color: Theme.of(context).colorScheme.primary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                BarChartRodData(toY: 4500, color: Theme.of(context).colorScheme.secondary, width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              value: 35,
              title: 'Food\n35%',
              color: Theme.of(context).colorScheme.secondary,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 25,
              title: 'Transport\n25%',
              color: Theme.of(context).colorScheme.primary,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 20,
              title: 'Shopping\n20%',
              color: Theme.of(context).colorScheme.tertiary,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 15,
              title: 'Bills\n15%',
              color: Theme.of(context).colorScheme.tertiary,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 5,
              title: 'Other\n5%',
              color: Theme.of(context).colorScheme.outline,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          _buildCategoryRow(
            name: 'Food & Dining',
            amount: 1250.00,
            percentage: 35,
            color: Theme.of(context).colorScheme.secondary,
            icon: Icons.restaurant,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Transportation',
            amount: 890.50,
            percentage: 25,
            color: Theme.of(context).colorScheme.primary,
            icon: Icons.directions_car,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Shopping',
            amount: 715.25,
            percentage: 20,
            color: Theme.of(context).colorScheme.tertiary,
            icon: Icons.shopping_bag,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Bills & Utilities',
            amount: 536.75,
            percentage: 15,
            color: Theme.of(context).colorScheme.tertiary,
            icon: Icons.receipt_long,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Others',
            amount: 178.00,
            percentage: 5,
            color: Theme.of(context).colorScheme.outline,
            icon: Icons.more_horiz,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required String name,
    required double amount,
    required int percentage,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: AppTouchTarget.min,
            height: AppTouchTarget.min,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountText.small(
                amount: amount,
                type: AmountType.neutral,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$percentage%',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Report period enum
enum ReportPeriod {
  week,
  month,
  year,
}
