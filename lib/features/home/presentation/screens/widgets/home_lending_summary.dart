import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class HomeLendingSummary extends StatefulWidget {
  const HomeLendingSummary({super.key});

  @override
  State<HomeLendingSummary> createState() => _HomeLendingSummaryState();
}

class _HomeLendingSummaryState extends State<HomeLendingSummary> {
  _LendingSummaryData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lendingRepo =
          SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getLendingRepository();
      final repaymentRepo =
          SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getLendingRepaymentRepository();

      final lendings = await lendingRepo.getAllLendings();
      final active = lendings.where((l) => l.status == 'active').toList();

      double totalReceivable = 0.0;
      LndngLending? nearestDue;

      for (final l in active) {
        final outstanding = await lendingRepo.getOutstandingAmount(l.id);
        totalReceivable += outstanding;
        if (l.dueDate != null) {
          if (nearestDue == null || l.dueDate!.isBefore(nearestDue.dueDate!)) {
            nearestDue = l;
          }
        }
      }

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      double receivedThisMonth = 0.0;
      for (final l in lendings) {
        final reps = await repaymentRepo.getRepaymentsForLending(l.id);
        receivedThisMonth += reps
            .where((r) => r.repaymentDate.isAfter(monthStart))
            .fold(0.0, (s, r) => s + r.amount);
      }

      if (mounted) {
        setState(() {
          _data = _LendingSummaryData(
            activeCount: active.length,
            totalReceivable: totalReceivable,
            nearestDueLending: nearestDue,
            receivedThisMonth: receivedThisMonth,
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
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _data;
    if (data == null || data.activeCount == 0) return const SizedBox.shrink();

    final fmt = NumberFormat.currency(symbol: 'RM ');
    final dateFmt = DateFormat('dd MMM yyyy');
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.lendings),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.volunteer_activism_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Money Lent Out',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryChip(
                    label: 'Active',
                    value: '${data.activeCount}',
                    valueColor: colorScheme.primary,
                  ),
                  _SummaryChip(
                    label: 'Total Receivable',
                    value: fmt.format(data.totalReceivable),
                    valueColor: data.totalReceivable > 0
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  _SummaryChip(
                    label: 'Received This Month',
                    value: fmt.format(data.receivedThisMonth),
                    valueColor: colorScheme.primary,
                  ),
                ],
              ),
              if (data.nearestDueLending != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _dueDateColor(
                      context,
                      data.nearestDueLending!.dueDate!,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: _dueDateColor(
                          context,
                          data.nearestDueLending!.dueDate!,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.nearestDueLending!.borrowerName} — due ${dateFmt.format(data.nearestDueLending!.dueDate!)}',
                        style: AppTextStyles.caption.copyWith(
                          color: _dueDateColor(
                            context,
                            data.nearestDueLending!.dueDate!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _dueDateColor(BuildContext context, DateTime dueDate) {
    final d = dueDate.difference(DateTime.now()).inDays;
    if (d < 0) return Theme.of(context).colorScheme.error;
    if (d <= 7) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _LendingSummaryData {
  final int activeCount;
  final double totalReceivable;
  final LndngLending? nearestDueLending;
  final double receivedThisMonth;

  const _LendingSummaryData({
    required this.activeCount,
    required this.totalReceivable,
    required this.nearestDueLending,
    required this.receivedThisMonth,
  });
}
