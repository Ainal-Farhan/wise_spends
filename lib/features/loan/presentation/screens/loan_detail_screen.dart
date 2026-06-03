import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_detail_bloc.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_detail_event.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_detail_state.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

// ── urgency helpers (mirrors list screen) ─────────────────────────────────────

enum _DueUrgency { overdue, soon, upcoming, none }

_DueUrgency _urgency(DateTime? dueDate) {
  if (dueDate == null) return _DueUrgency.none;
  final days = dueDate.difference(DateTime.now()).inDays;
  if (days < 0) return _DueUrgency.overdue;
  if (days <= 7) return _DueUrgency.soon;
  if (days <= 60) return _DueUrgency.upcoming;
  return _DueUrgency.none;
}

Color _urgencyColor(BuildContext context, _DueUrgency u) {
  final cs = Theme.of(context).colorScheme;
  return switch (u) {
    _DueUrgency.overdue => cs.error,
    _DueUrgency.soon => Colors.orange,
    _DueUrgency.upcoming => Colors.amber.shade700,
    _DueUrgency.none => cs.primary,
  };
}

// ── screen ────────────────────────────────────────────────────────────────────

class LoanDetailScreen extends StatelessWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
    return BlocProvider(
      create: (_) => LoanDetailBloc(
        locator.getLoanRepository(),
        locator.getLoanRepaymentRepository(),
      )..add(LoadLoanDetailEvent(loanId)),
      child: const _LoanDetailContent(),
    );
  }
}

class _LoanDetailContent extends StatelessWidget {
  const _LoanDetailContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoanDetailBloc, LoanDetailState>(
      builder: (context, state) {
        if (state is LoanDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is LoanDetailError) {
          return Scaffold(
            appBar: AppBar(title: Text('general.error'.tr)),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is LoanDetailLoaded) {
          return _LoanDetailBody(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LoanDetailBody extends StatelessWidget {
  final LoanDetailLoaded state;

  const _LoanDetailBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loan = state.loan;
    final isSettled = loan.status == 'settled';
    final urgency = _urgency(loan.dueDate);
    final urgencyColor = _urgencyColor(context, urgency);

    final paidPct = loan.principalAmount > 0
        ? ((loan.principalAmount - state.outstanding) / loan.principalAmount)
            .clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(loan.borrowerName),
        centerTitle: false,
        actions: [
          if (!isSettled)
            TextButton.icon(
              onPressed: () => _confirmSettle(context, loan.id, loan.borrowerName),
              icon: Icon(Icons.check_circle_outline, size: 18, color: cs.primary),
              label: Text(
                'loan.btn_settle'.tr,
                style: TextStyle(color: cs.primary),
              ),
            ),
        ],
      ),
      floatingActionButton: isSettled
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  _showAddRepaymentSheet(context, loan.id, state.outstanding),
              icon: const Icon(Icons.payments_outlined),
              label: Text('loan.record_repayment'.tr),
            ),
      body: CustomScrollView(
        slivers: [
          // ── header card ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeaderCard(
              state: state,
              urgency: urgency,
              urgencyColor: urgencyColor,
              paidPct: paidPct,
            ),
          ),
          // ── urgency banner (overdue / soon) ────────────────────────────────
          if (!isSettled && urgency != _DueUrgency.none && loan.dueDate != null)
            SliverToBoxAdapter(
              child: _UrgencyBanner(
                dueDate: loan.dueDate!,
                urgency: urgency,
                urgencyColor: urgencyColor,
              ),
            ),
          // ── repayments section header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'loan.repayments_title'.tr,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (state.repayments.isNotEmpty)
                    Text(
                      'loan.repayments_count'.trWith(
                        {'count': state.repayments.length.toString()},
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ── repayments list ────────────────────────────────────────────────
          if (state.repayments.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: cs.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'loan.repayments_empty'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxxl + 56,
              ),
              sliver: SliverList.separated(
                itemCount: state.repayments.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  // show most recent first
                  final r = state.repayments[
                      state.repayments.length - 1 - index];
                  return _RepaymentTile(repayment: r, index: index);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmSettle(BuildContext context, String loanId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, size: 32),
        title: Text('loan.settle_title'.tr),
        content: Text('loan.settle_confirm'.trWith({'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LoanDetailBloc>().add(SettleLoanEvent(loanId));
            },
            child: Text('loan.btn_settle'.tr),
          ),
        ],
      ),
    );
  }

  void _showAddRepaymentSheet(
      BuildContext context, String loanId, double outstanding) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddRepaymentSheet(
        outstanding: outstanding,
        onAdd: (amount, destinationSavingId, date, note) {
          context.read<LoanDetailBloc>().add(
            AddRepaymentEvent(
              loanId: loanId,
              amount: amount,
              destinationSavingId: destinationSavingId,
              repaymentDate: date,
              note: note,
            ),
          );
        },
      ),
    );
  }
}

// ── header card ───────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final LoanDetailLoaded state;
  final _DueUrgency urgency;
  final Color urgencyColor;
  final double paidPct;

  const _HeaderCard({
    required this.state,
    required this.urgency,
    required this.urgencyColor,
    required this.paidPct,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loan = state.loan;
    final isSettled = loan.status == 'settled';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSettled
              ? [cs.primaryContainer, cs.primaryContainer.withValues(alpha: 0.6)]
              : urgency == _DueUrgency.overdue
                  ? [
                      cs.errorContainer,
                      cs.errorContainer.withValues(alpha: 0.6),
                    ]
                  : [
                      cs.primaryContainer,
                      cs.secondaryContainer.withValues(alpha: 0.7),
                    ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── borrower + status ──────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.surface.withValues(alpha: 0.4),
                child: Text(
                  loan.borrowerName.isNotEmpty
                      ? loan.borrowerName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.h3.copyWith(
                    color: isSettled ? cs.primary : cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  loan.borrowerName,
                  style: AppTextStyles.h3.copyWith(
                    color: isSettled
                        ? cs.onPrimaryContainer
                        : cs.onPrimaryContainer,
                  ),
                ),
              ),
              AppBadge(
                label: isSettled
                    ? 'loan.status_settled'.tr
                    : 'loan.status_active'.tr,
                status: isSettled
                    ? AppBadgeStatus.success
                    : AppBadgeStatus.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── outstanding highlight ──────────────────────────────────────────
          if (!isSettled) ...[
            Text(
              'loan.label_outstanding'.tr,
              style: AppTextStyles.caption.copyWith(
                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _currFmt.format(state.outstanding),
              style: AppTextStyles.h2.copyWith(
                color: state.outstanding > 0
                    ? cs.error
                    : cs.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ] else ...[
            Text(
              'loan.label_fully_repaid'.tr,
              style: AppTextStyles.bodyLarge.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // ── progress bar ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: paidPct,
                    minHeight: 8,
                    backgroundColor: cs.surface.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(
                      isSettled ? cs.primary : cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${(paidPct * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // ── principal + dates ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.attach_money,
                  label: 'loan.label_principal'.tr,
                  value: _currFmt.format(loan.principalAmount),
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'loan.field_loan_date_prefix'.tr,
                  value: _dateFmt.format(loan.loanDate),
                ),
              ),
              if (loan.dueDate != null)
                Expanded(
                  child: _InfoItem(
                    icon: Icons.event_outlined,
                    label: 'loan.field_due_date_prefix'.tr,
                    value: _dateFmt.format(loan.dueDate!),
                    valueColor: urgencyColor,
                  ),
                ),
            ],
          ),
          // ── note ──────────────────────────────────────────────────────────
          if (loan.note != null && loan.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notes_outlined,
                    size: 14,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      loan.note!,
                      style: AppTextStyles.caption.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: cs.onPrimaryContainer.withValues(alpha: 0.6)),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: cs.onPrimaryContainer.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

// ── urgency banner ────────────────────────────────────────────────────────────

class _UrgencyBanner extends StatelessWidget {
  final DateTime dueDate;
  final _DueUrgency urgency;
  final Color urgencyColor;

  const _UrgencyBanner({
    required this.dueDate,
    required this.urgency,
    required this.urgencyColor,
  });

  @override
  Widget build(BuildContext context) {
    final days = dueDate.difference(DateTime.now()).inDays;
    String message;
    IconData icon;
    if (urgency == _DueUrgency.overdue) {
      message = 'loan.banner_overdue'.trWith({'days': (-days).toString()});
      icon = Icons.warning_amber_rounded;
    } else if (urgency == _DueUrgency.soon) {
      message = 'loan.banner_due_soon'.trWith({'days': days.toString()});
      icon = Icons.schedule_rounded;
    } else {
      message = 'loan.banner_due_upcoming'.trWith(
          {'date': _dateFmt.format(dueDate)});
      icon = Icons.event_rounded;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: urgencyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: urgencyColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: urgencyColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: urgencyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── repayment tile ────────────────────────────────────────────────────────────

class _RepaymentTile extends StatelessWidget {
  final dynamic repayment;
  final int index;

  const _RepaymentTile({required this.repayment, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = repayment;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.payments_outlined,
                size: 18,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateFmt.format(r.repaymentDate),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (r.note != null && r.note!.isNotEmpty)
                    Text(
                      r.note!,
                      style: AppTextStyles.caption.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              _currFmt.format(r.amount),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── add repayment sheet ───────────────────────────────────────────────────────

class _AddRepaymentSheet extends StatefulWidget {
  final double outstanding;
  final void Function(
    double amount,
    String destinationSavingId,
    DateTime repaymentDate,
    String? note,
  ) onAdd;

  const _AddRepaymentSheet({
    required this.outstanding,
    required this.onAdd,
  });

  @override
  State<_AddRepaymentSheet> createState() => _AddRepaymentSheetState();
}

class _AddRepaymentSheetState extends State<_AddRepaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _repaymentDate = DateTime.now();
  FormAccountItem? _selectedSaving;
  List<FormAccountItem> _savings = [];

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    try {
      final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getSavingRepository();
      final savings = await repo.getAllSavings();
      if (mounted) {
        setState(() => _savings = savings.map((s) => s.toFormAccountItem()).toList());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Text('loan.record_repayment'.tr, style: AppTextStyles.h3),
              if (widget.outstanding > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'loan.outstanding_hint'.trWith(
                    {'amount': _currFmt.format(widget.outstanding)},
                  ),
                  style: AppTextStyles.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              // ── quick fill buttons ───────────────────────────────────────
              if (widget.outstanding > 0) ...[
                Row(
                  children: [
                    _QuickFillChip(
                      label: '25%',
                      onTap: () => _amountCtrl.text =
                          (widget.outstanding * 0.25).toStringAsFixed(2),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _QuickFillChip(
                      label: '50%',
                      onTap: () => _amountCtrl.text =
                          (widget.outstanding * 0.5).toStringAsFixed(2),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _QuickFillChip(
                      label: 'loan.full_amount'.tr,
                      onTap: () => _amountCtrl.text =
                          widget.outstanding.toStringAsFixed(2),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              AppTextField(
                controller: _amountCtrl,
                label: 'loan.repayment_amount'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'general.must_be_positive'.tr;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              FormField<FormAccountItem>(
                validator: (_) => _selectedSaving == null
                    ? 'general.required'.tr
                    : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormAccountSelector(
                      label: 'loan.repayment_destination'.tr,
                      selectedAccount: _selectedSaving,
                      accounts: _savings,
                      onAccountSelected: (a) =>
                          setState(() => _selectedSaving = a),
                    ),
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _repaymentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _repaymentDate = picked);
                },
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 18, color: cs.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${'loan.repayment_date_prefix'.tr}: ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _dateFmt.format(_repaymentDate),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'loan.repayment_btn'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      double.parse(_amountCtrl.text),
                      _selectedSaving!.id,
                      _repaymentDate,
                      _noteCtrl.text.trim().isEmpty
                          ? null
                          : _noteCtrl.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickFillChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickFillChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
