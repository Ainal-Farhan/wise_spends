import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class HomeLoanSummary extends StatefulWidget {
  const HomeLoanSummary({super.key});

  @override
  State<HomeLoanSummary> createState() => _HomeLoanSummaryState();
}

class _HomeLoanSummaryState extends State<HomeLoanSummary> {
  _LoanSummaryData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loanRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getLoanRepository();
      final repaymentRepo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getLoanRepaymentRepository();

      final loans = await loanRepo.getAllLoans();
      final activeLoans = loans.where((l) => l.status == 'active').toList();

      double totalOutstanding = 0.0;
      LoanLoan? nearestDue;

      for (final loan in activeLoans) {
        final outstanding = await loanRepo.getOutstandingAmount(loan.id);
        totalOutstanding += outstanding;
        if (loan.dueDate != null) {
          if (nearestDue == null ||
              loan.dueDate!.isBefore(nearestDue.dueDate!)) {
            nearestDue = loan;
          }
        }
      }

      final repaymentsThisMonth = <LoanRepayment>[];
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      for (final loan in loans) {
        final reps = await repaymentRepo.getRepaymentsForLoan(loan.id);
        repaymentsThisMonth.addAll(
          reps.where((r) => r.repaymentDate.isAfter(monthStart)),
        );
      }
      final repaidThisMonth = repaymentsThisMonth.fold<double>(
        0.0,
        (s, r) => s + r.amount,
      );

      if (mounted) {
        setState(() {
          _data = _LoanSummaryData(
            activeCount: activeLoans.length,
            totalOutstanding: totalOutstanding,
            nearestDueLoan: nearestDue,
            repaidThisMonth: repaidThisMonth,
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
      onTap: () => Navigator.pushNamed(context, AppRoutes.loans),
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
                      color: colorScheme.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.handshake_outlined,
                      size: 20,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'home.loans_outstanding'.tr,
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
                    label: 'home.loans_active'.tr,
                    value: '${data.activeCount}',
                    valueColor: colorScheme.tertiary,
                  ),
                  _SummaryChip(
                    label: 'home.loans_total_outstanding'.tr,
                    value: fmt.format(data.totalOutstanding),
                    valueColor: data.totalOutstanding > 0
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                  _SummaryChip(
                    label: 'home.loans_repaid_month'.tr,
                    value: fmt.format(data.repaidThisMonth),
                    valueColor: colorScheme.primary,
                  ),
                ],
              ),
              if (data.nearestDueLoan != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _dueDateColor(
                      context,
                      data.nearestDueLoan!.dueDate!,
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
                          data.nearestDueLoan!.dueDate!,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'home.loans_nearest_due'.trWith({
                          'name': data.nearestDueLoan!.borrowerName,
                          'date': dateFmt.format(data.nearestDueLoan!.dueDate!),
                        }),
                        style: AppTextStyles.caption.copyWith(
                          color: _dueDateColor(
                            context,
                            data.nearestDueLoan!.dueDate!,
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
    final daysUntil = dueDate.difference(DateTime.now()).inDays;
    if (daysUntil < 0) return Theme.of(context).colorScheme.error;
    if (daysUntil <= 7) return Colors.orange;
    return Theme.of(context).colorScheme.tertiary;
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

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

class _LoanSummaryData {
  final int activeCount;
  final double totalOutstanding;
  final LoanLoan? nearestDueLoan;
  final double repaidThisMonth;

  const _LoanSummaryData({
    required this.activeCount,
    required this.totalOutstanding,
    required this.nearestDueLoan,
    required this.repaidThisMonth,
  });
}
