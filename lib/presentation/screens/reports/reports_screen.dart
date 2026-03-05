import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wise_spends/data/services/reports_export_service.dart';

/// Reports/Analytics Screen
/// Features:
/// - Period selector (Week/Month/Year)
/// - Bar chart for income vs expenses over time
/// - Donut chart for expense breakdown by category
/// - Summary cards with vs last period indicators
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
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () async {
              try {
                // Export report to CSV
                final exportService = ReportsExportService();
                final filePath = await exportService.exportReportToCsv(
                  period: _selectedPeriod.name,
                  totalIncome: 5420.00, // Placeholder - integrate with BLoC for real data
                  totalExpenses: 3250.50, // Placeholder - integrate with BLoC for real data
                  totalBalance: 2169.50, // Placeholder - integrate with BLoC for real data
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
                  const SnackBar(
                    content: Text('Report exported successfully'),
                    backgroundColor: WiseSpendsColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export failed: ${e.toString()}'),
                    backgroundColor: WiseSpendsColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(),
            const SizedBox(height: UIConstants.spacingXXL),

            // Summary cards
            _buildSummaryCards(),
            const SizedBox(height: UIConstants.spacingXXL),

            // Income vs Expenses bar chart
            Text(
              'Income vs Expenses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            _buildBarChart(),
            const SizedBox(height: UIConstants.spacingXXL),

            // Expense breakdown donut chart
            Text(
              'Expense Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            _buildDonutChart(),
            const SizedBox(height: UIConstants.spacingXXL),

            // Category-wise breakdown
            Text(
              'By Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            _buildCategoryBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.radiusXLarge),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      padding: const EdgeInsets.all(UIConstants.spacingXS),
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
        padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingSmall),
        decoration: BoxDecoration(
          color: isSelected ? WiseSpendsColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusXLarge),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : WiseSpendsColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
              child: _buildSummaryCard(
                title: 'Income',
                amount: 5420.00,
                type: TransactionType.income,
                vsLastPeriod: 12.5,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Expanded(
              child: _buildSummaryCard(
                title: 'Expenses',
                amount: 3250.50,
                type: TransactionType.expense,
                vsLastPeriod: -8.2,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Savings',
                amount: 2169.50,
                type: TransactionType.transfer,
                vsLastPeriod: 25.3,
                icon: Icons.savings_outlined,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMedium),
            Expanded(
              child: _buildSummaryCard(
                title: 'Balance',
                amount: 8750.25,
                type: TransactionType.transfer,
                vsLastPeriod: 5.7,
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required TransactionType type,
    required double vsLastPeriod,
    required IconData icon,
  }) {
    final color = _getColorForType(type);
    final isPositive = vsLastPeriod >= 0;

    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: UIConstants.iconMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingSmall,
                  vertical: UIConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? WiseSpendsColors.success.withValues(alpha: 0.1)
                      : WiseSpendsColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive
                          ? WiseSpendsColors.success
                          : WiseSpendsColors.secondary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${vsLastPeriod.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isPositive
                            ? WiseSpendsColors.success
                            : WiseSpendsColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
          ),
          const SizedBox(height: UIConstants.spacingXS),
          Text(
            NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return WiseSpendsColors.success;
      case TransactionType.expense:
        return WiseSpendsColors.secondary;
      case TransactionType.transfer:
        return WiseSpendsColors.tertiary;
    }
  }

  Widget _buildBarChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        border: Border.all(color: WiseSpendsColors.divider),
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
                        style: TextStyle(
                          color: WiseSpendsColors.textSecondary,
                          fontSize: 12,
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
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(toY: 5000, color: WiseSpendsColors.success, width: 12),
                BarChartRodData(toY: 3000, color: WiseSpendsColors.secondary, width: 12),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: 6000, color: WiseSpendsColors.success, width: 12),
                BarChartRodData(toY: 4000, color: WiseSpendsColors.secondary, width: 12),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: 4500, color: WiseSpendsColors.success, width: 12),
                BarChartRodData(toY: 3500, color: WiseSpendsColors.secondary, width: 12),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(toY: 7000, color: WiseSpendsColors.success, width: 12),
                BarChartRodData(toY: 4500, color: WiseSpendsColors.secondary, width: 12),
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
      padding: const EdgeInsets.all(UIConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              value: 35,
              title: 'Food\n35%',
              color: WiseSpendsColors.secondary,
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
              color: WiseSpendsColors.primary,
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
              color: WiseSpendsColors.tertiary,
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
              color: WiseSpendsColors.warning,
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
              color: WiseSpendsColors.textHint,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        children: [
          _buildCategoryRow(
            name: 'Food & Dining',
            amount: 1250.00,
            percentage: 35,
            color: WiseSpendsColors.secondary,
            icon: Icons.restaurant,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Transportation',
            amount: 890.50,
            percentage: 25,
            color: WiseSpendsColors.primary,
            icon: Icons.directions_car,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Shopping',
            amount: 715.25,
            percentage: 20,
            color: WiseSpendsColors.tertiary,
            icon: Icons.shopping_bag,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Bills & Utilities',
            amount: 536.75,
            percentage: 15,
            color: WiseSpendsColors.warning,
            icon: Icons.receipt_long,
          ),
          const Divider(height: 1),
          _buildCategoryRow(
            name: 'Others',
            amount: 178.00,
            percentage: 5,
            color: WiseSpendsColors.textHint,
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
      padding: const EdgeInsets.all(UIConstants.spacingLarge),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
            ),
            child: Icon(
              icon,
              color: color,
              size: UIConstants.iconMedium,
            ),
          ),
          const SizedBox(width: UIConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
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
          const SizedBox(width: UIConstants.spacingMedium),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: 'RM', decimalDigits: 2).format(amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WiseSpendsColors.textSecondary,
                    ),
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
