import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/lending/presentation/bloc/lending_detail_bloc.dart';
import 'package:wise_spends/features/lending/presentation/bloc/lending_detail_event.dart';
import 'package:wise_spends/features/lending/presentation/bloc/lending_detail_state.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

enum _DueUrgency { overdue, soon, upcoming, none }

_DueUrgency _urgency(DateTime? d) {
  if (d == null) return _DueUrgency.none;
  final days = d.difference(DateTime.now()).inDays;
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

class LendingDetailScreen extends StatelessWidget {
  final String lendingId;

  const LendingDetailScreen({super.key, required this.lendingId});

  @override
  Widget build(BuildContext context) {
    final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
    return BlocProvider(
      create: (_) => LendingDetailBloc(
        locator.getLendingRepository(),
        locator.getLendingRepaymentRepository(),
      )..add(LoadLendingDetailEvent(lendingId)),
      child: const _LendingDetailContent(),
    );
  }
}

class _LendingDetailContent extends StatelessWidget {
  const _LendingDetailContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LendingDetailBloc, LendingDetailState>(
      builder: (context, state) {
        if (state is LendingDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is LendingDetailError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is LendingDetailLoaded) {
          return _LendingDetailBody(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LendingDetailBody extends StatelessWidget {
  final LendingDetailLoaded state;

  const _LendingDetailBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lending = state.lending;
    final isSettled = lending.status == 'settled';
    final urgency = _urgency(lending.dueDate);
    final urgencyColor = _urgencyColor(context, urgency);
    final paidPct = lending.principalAmount > 0
        ? ((lending.principalAmount - state.outstanding) /
                  lending.principalAmount)
              .clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(lending.borrowerName),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _showEditSheet(context, state),
          ),
          if (!isSettled)
            TextButton.icon(
              onPressed: () =>
                  _confirmSettle(context, lending.id, lending.borrowerName),
              icon: Icon(
                Icons.check_circle_outline,
                size: 18,
                color: cs.primary,
              ),
              label: Text('Settle', style: TextStyle(color: cs.primary)),
            ),
        ],
      ),
      floatingActionButton: isSettled
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddRepaymentSheet(
                context,
                lending.id,
                state.outstanding,
              ),
              icon: const Icon(Icons.savings_outlined),
              label: const Text('Record Repayment'),
            ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeaderCard(
              state: state,
              urgency: urgency,
              urgencyColor: urgencyColor,
              paidPct: paidPct,
            ),
          ),
          if (!isSettled &&
              urgency != _DueUrgency.none &&
              lending.dueDate != null)
            SliverToBoxAdapter(
              child: _UrgencyBanner(
                dueDate: lending.dueDate!,
                urgency: urgency,
                urgencyColor: urgencyColor,
              ),
            ),
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
                    'Repayments',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (state.repayments.isNotEmpty)
                    Text(
                      '${state.repayments.length} record(s)',
                      style: AppTextStyles.caption.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
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
                      'No repayments yet',
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
                  final r = state.repayments[index];
                  return _RepaymentTile(repayment: r, index: index);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, LendingDetailLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _EditLendingSheet(
        existing: state.lending,
        onSave:
            (
              borrowerName,
              principalAmount,
              lendingDate,
              dueDate,
              note,
              noAutoDeduct,
            ) {
              context.read<LendingDetailBloc>().add(
                UpdateLendingEvent(
                  lendingId: state.lending.id,
                  borrowerName: borrowerName,
                  principalAmount: principalAmount,
                  lendingDate: lendingDate,
                  dueDate: dueDate,
                  note: note,
                  noAutoDeduct: noAutoDeduct,
                ),
              );
            },
      ),
    );
  }

  void _confirmSettle(BuildContext context, String lendingId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, size: 32),
        title: const Text('Mark as Settled'),
        content: Text('Mark lending to "$name" as fully settled?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LendingDetailBloc>().add(
                SettleLendingEvent(lendingId),
              );
            },
            child: const Text('Settle'),
          ),
        ],
      ),
    );
  }

  void _showAddRepaymentSheet(
    BuildContext context,
    String lendingId,
    double outstanding,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddRepaymentSheet(
        outstanding: outstanding,
        onAdd: (amount, destinationSavingId, date, note) {
          context.read<LendingDetailBloc>().add(
            AddLendingRepaymentEvent(
              lendingId: lendingId,
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

// ── Header card ────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final LendingDetailLoaded state;
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
    final lending = state.lending;
    final isSettled = lending.status == 'settled';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSettled
              ? [
                  cs.primaryContainer,
                  cs.primaryContainer.withValues(alpha: 0.6),
                ]
              : urgency == _DueUrgency.overdue
              ? [cs.errorContainer, cs.errorContainer.withValues(alpha: 0.6)]
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
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.surface.withValues(alpha: 0.4),
                child: Text(
                  lending.borrowerName.isNotEmpty
                      ? lending.borrowerName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.h3.copyWith(
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lending.borrowerName,
                      style: AppTextStyles.h3.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Lent on ${_dateFmt.format(lending.lendingDate)}',
                      style: AppTextStyles.caption.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: isSettled ? 'Settled' : 'Active',
                status: isSettled
                    ? AppBadgeStatus.success
                    : AppBadgeStatus.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Lent',
                  value: _currFmt.format(lending.principalAmount),
                ),
              ),
              Expanded(
                child: _StatChip(
                  label: 'Receivable',
                  value: _currFmt.format(state.outstanding),
                  valueColor: state.outstanding > 0 ? cs.primary : null,
                ),
              ),
              Expanded(
                child: _StatChip(
                  label: 'Repaid',
                  value: _currFmt.format(
                    lending.principalAmount - state.outstanding,
                  ),
                  valueColor: cs.onPrimaryContainer,
                ),
              ),
            ],
          ),
          if (!isSettled) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: paidPct,
                      minHeight: 6,
                      backgroundColor: cs.onPrimaryContainer.withValues(
                        alpha: 0.15,
                      ),
                      valueColor: AlwaysStoppedAnimation(cs.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${(paidPct * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
          if (lending.dueDate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Expected return: ${_dateFmt.format(lending.dueDate!)}',
              style: AppTextStyles.caption.copyWith(
                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (lending.note != null && lending.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              lending.note!,
              style: AppTextStyles.caption.copyWith(
                color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: cs.onPrimaryContainer.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

// ── Urgency banner ─────────────────────────────────────────────────────────────

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
    final message = urgency == _DueUrgency.overdue
        ? 'Overdue by ${(-days)} days — expected return date passed!'
        : 'Due in $days days — follow up soon';

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: urgencyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 16, color: urgencyColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
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

// ── Repayment tile ─────────────────────────────────────────────────────────────

class _RepaymentTile extends StatelessWidget {
  final LndngRepayment repayment;
  final int index;

  const _RepaymentTile({required this.repayment, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.savings_outlined, size: 18, color: cs.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateFmt.format(repayment.repaymentDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (repayment.note != null && repayment.note!.isNotEmpty)
                  Text(
                    repayment.note!,
                    style: AppTextStyles.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _currFmt.format(repayment.amount),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add repayment sheet ────────────────────────────────────────────────────────

class _AddRepaymentSheet extends StatefulWidget {
  final double outstanding;
  final void Function(
    double amount,
    String destinationSavingId,
    DateTime date,
    String? note,
  )
  onAdd;

  const _AddRepaymentSheet({required this.outstanding, required this.onAdd});

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
        setState(
          () => _savings = savings.map((s) => s.toFormAccountItem()).toList(),
        );
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
              Text('Record Repayment', style: AppTextStyles.h3),
              if (widget.outstanding > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Outstanding: ${_currFmt.format(widget.outstanding)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _amountCtrl,
                label: 'Amount Received',
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Must be positive';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              FormField<FormAccountItem>(
                validator: (_) => _selectedSaving == null ? 'Required' : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormAccountSelector(
                      label: 'Deposit to Account',
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
                          style: TextStyle(color: cs.error, fontSize: 12),
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
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: cs.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Date: ',
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
              const SizedBox(height: AppSpacing.sm),
              AppTextField(controller: _noteCtrl, label: 'Note (optional)'),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'Record',
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

// ── Edit lending sheet ─────────────────────────────────────────────────────────

class _EditLendingSheet extends StatefulWidget {
  final LndngLending existing;
  final void Function(
    String borrowerName,
    double principalAmount,
    DateTime lendingDate,
    DateTime? dueDate,
    String? note,
    bool noAutoDeduct,
  )
  onSave;

  const _EditLendingSheet({required this.existing, required this.onSave});

  @override
  State<_EditLendingSheet> createState() => _EditLendingSheetState();
}

class _EditLendingSheetState extends State<_EditLendingSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _borrowerCtrl = TextEditingController(
    text: widget.existing.borrowerName,
  );
  late final _amountCtrl = TextEditingController(
    text: widget.existing.principalAmount.toStringAsFixed(2),
  );
  late final _noteCtrl = TextEditingController(
    text: widget.existing.note ?? '',
  );
  late DateTime _lendingDate = widget.existing.lendingDate;
  late DateTime? _dueDate = widget.existing.dueDate;
  late final bool _noAutoDeduct = widget.existing.noAutoDeduct;

  @override
  void dispose() {
    _borrowerCtrl.dispose();
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
              Text('Edit Lending', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _borrowerCtrl,
                label: 'Borrower Name',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountCtrl,
                label: 'Amount',
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Must be positive';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _lendingDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _lendingDate = picked);
                },
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: cs.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Lending date: ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _dateFmt.format(_lendingDate),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_outlined, size: 18, color: cs.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Return date: ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _dueDate != null
                            ? _dateFmt.format(_dueDate!)
                            : 'Not set',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _dueDate = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(controller: _noteCtrl, label: 'Note (optional)'),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'Save',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(
                      _borrowerCtrl.text.trim(),
                      double.parse(_amountCtrl.text),
                      _lendingDate,
                      _dueDate,
                      _noteCtrl.text.trim().isEmpty
                          ? null
                          : _noteCtrl.text.trim(),
                      _noAutoDeduct,
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
