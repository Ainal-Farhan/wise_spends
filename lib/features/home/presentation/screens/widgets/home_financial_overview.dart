import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

// ── Public widget ─────────────────────────────────────────────────────────────

class HomeFinancialOverview extends StatefulWidget {
  const HomeFinancialOverview({super.key});

  @override
  State<HomeFinancialOverview> createState() => _HomeFinancialOverviewState();
}

class _HomeFinancialOverviewState extends State<HomeFinancialOverview> {
  _OverviewData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
      final savingRepo = locator.getSavingRepository();
      final txRepo = locator.getTransactionRepository();

      // ── Savings health ────────────────────────────────────────────────────
      final savings = await savingRepo.getAllSavings();
      double totalSaved = 0;
      double totalReserved = 0;

      for (final s in savings) {
        totalSaved += s.currentAmount;
        totalReserved += s.reservedAmount;
      }
      final available = (totalSaved - totalReserved).clamp(0.0, double.infinity);

      // ── 7-day daily expenses ──────────────────────────────────────────────
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sevenDaysAgo = today.subtract(const Duration(days: 6));

      final recentTx = await txRepo.fetchByDateRange(
        from: sevenDaysAgo,
        to: now,
      );

      // Bucket expenses by day-offset (0 = 6 days ago, 6 = today)
      final dailyExpenses = List<double>.filled(7, 0);
      for (final tx in recentTx) {
        if (tx.type.name == 'expense') {
          final dayOffset =
              tx.date.difference(sevenDaysAgo).inDays.clamp(0, 6);
          dailyExpenses[dayOffset] += tx.amount.abs();
        }
      }

      if (mounted) {
        setState(() {
          _data = _OverviewData(
            totalSaved: totalSaved,
            totalReserved: totalReserved,
            available: available,
            dailyExpenses: dailyExpenses,
          );
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _OverviewShimmer();
    final data = _data;
    if (data == null || data.totalSaved == 0) return const SizedBox.shrink();
    return _OverviewCard(data: data);
  }
}

// ── Data holder ───────────────────────────────────────────────────────────────

class _OverviewData {
  final double totalSaved;
  final double totalReserved;
  final double available;
  final List<double> dailyExpenses; // 7 entries: day-6 … today

  const _OverviewData({
    required this.totalSaved,
    required this.totalReserved,
    required this.available,
    required this.dailyExpenses,
  });
}

// ── Main card ─────────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final _OverviewData data;

  const _OverviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(
                  Icons.savings_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'home.financial_overview'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Ring + stats row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SavingsRing(data: data),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _SavingsStats(data: data)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Divider + sparkline
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SpendingSparkline(dailyExpenses: data.dailyExpenses),
          ],
        ),
      ),
    );
  }
}

// ── Savings ring (PieChart donut) ─────────────────────────────────────────────

class _SavingsRing extends StatelessWidget {
  final _OverviewData data;

  const _SavingsRing({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final reserved = data.totalReserved.clamp(0.0, data.totalSaved);
    final available = data.available;
    final total = data.totalSaved;

    // If nothing, show empty grey ring
    if (total == 0) {
      return SizedBox(
        width: 90,
        height: 90,
        child: PieChart(PieChartData(
          sections: [
            PieChartSectionData(
              value: 1,
              color: cs.onSurface.withValues(alpha: 0.1),
              radius: 14,
              showTitle: false,
            ),
          ],
          centerSpaceRadius: 31,
        )),
      );
    }

    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  value: available,
                  color: cs.primary,
                  radius: 16,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: reserved,
                  color: Colors.amber.shade600,
                  radius: 16,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${((available / total) * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: cs.primary,
                ),
              ),
              Text(
                'home.available'.tr,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Savings stats (right of ring) ─────────────────────────────────────────────

class _SavingsStats extends StatelessWidget {
  final _OverviewData data;

  const _SavingsStats({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatRow(
          dot: cs.primary,
          label: 'home.available'.tr,
          value: _currFmt.format(data.available),
          bold: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        _StatRow(
          dot: Colors.amber.shade600,
          label: 'home.reserved'.tr,
          value: _currFmt.format(data.totalReserved),
        ),
        const SizedBox(height: AppSpacing.xs),
        _StatRow(
          dot: cs.onSurface.withValues(alpha: 0.25),
          label: 'home.total_saved'.tr,
          value: _currFmt.format(data.totalSaved),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final Color dot;
  final String label;
  final String value;
  final bool bold;

  const _StatRow({
    required this.dot,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: cs.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── 7-day spending sparkline ──────────────────────────────────────────────────

class _SpendingSparkline extends StatelessWidget {
  final List<double> dailyExpenses; // 7 values

  const _SpendingSparkline({required this.dailyExpenses});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    final spots = List.generate(7, (i) {
      return FlSpot(i.toDouble(), dailyExpenses[i]);
    });

    final maxY = dailyExpenses.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxY < 1 ? 1.0 : maxY * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 14,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'home.spending_7d'.tr,
              style: AppTextStyles.caption.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 60,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    getTitlesWidget: (value, meta) {
                      final day = now
                          .subtract(Duration(days: 6 - value.toInt()))
                          .day;
                      return Text(
                        '$day',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: cs.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
              minY: 0,
              maxY: effectiveMax,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: cs.primary,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, pct, bar, idx) =>
                        FlDotCirclePainter(
                      radius: 2.5,
                      color: cs.primary,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.primary.withValues(alpha: 0.25),
                        cs.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _OverviewShimmer extends StatelessWidget {
  const _OverviewShimmer();

  @override
  Widget build(BuildContext context) {
    return const ShimmerBalanceCard(isHero: true);
  }
}
