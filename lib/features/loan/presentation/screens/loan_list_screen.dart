import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_list_bloc.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_list_event.dart';
import 'package:wise_spends/features/loan/presentation/bloc/loan_list_state.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

// ── urgency helpers ──────────────────────────────────────────────────────────

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
    _DueUrgency.none => cs.outline,
  };
}

IconData _urgencyIcon(_DueUrgency u) => switch (u) {
  _DueUrgency.overdue => Icons.warning_amber_rounded,
  _DueUrgency.soon => Icons.schedule_rounded,
  _DueUrgency.upcoming => Icons.event_rounded,
  _DueUrgency.none => Icons.event_available_rounded,
};

// ── filter enum ──────────────────────────────────────────────────────────────

enum _FilterTab { all, active, settled }

// ── screen ───────────────────────────────────────────────────────────────────

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getLoanRepository();
    return BlocProvider(
      create: (_) => LoanListBloc(repo)..add(LoadLoansEvent()),
      child: const _LoanListContent(),
    );
  }
}

class _LoanListContent extends StatefulWidget {
  const _LoanListContent();

  @override
  State<_LoanListContent> createState() => _LoanListContentState();
}

class _LoanListContentState extends State<_LoanListContent> {
  final _searchCtrl = TextEditingController();
  _FilterTab _tab = _FilterTab.all;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<LoanSummary> _filter(List<LoanSummary> all) {
    return all.where((s) {
      final matchesTab = switch (_tab) {
        _FilterTab.all => true,
        _FilterTab.active => s.loan.status == 'active',
        _FilterTab.settled => s.loan.status == 'settled',
      };
      final matchesSearch =
          _query.isEmpty ||
          s.loan.borrowerName.toLowerCase().contains(_query.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('loan.title'.tr), centerTitle: false),
      drawer: const NavigationSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLoanSheet(context),
        icon: const Icon(Icons.add),
        label: Text('loan.btn_add'.tr),
      ),
      body: BlocBuilder<LoanListBloc, LoanListState>(
        builder: (context, state) {
          if (state is LoanListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LoanError) {
            return Center(child: Text(state.message));
          }
          if (state is LoanListLoaded) {
            final summaries = _filter(state.summaries);
            final activeCount = state.summaries
                .where((s) => s.loan.status == 'active')
                .length;
            final totalOutstanding = state.summaries
                .where((s) => s.loan.status == 'active')
                .fold(0.0, (sum, s) => sum + s.outstanding);

            return Column(
              children: [
                // ── summary bar ──────────────────────────────────────────────
                if (state.summaries.isNotEmpty)
                  _SummaryBar(
                    activeCount: activeCount,
                    totalOutstanding: totalOutstanding,
                  ),
                // ── search ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'loan.search_hint'.tr,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                // ── filter tabs ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: _FilterTab.values.map((tab) {
                      final selected = _tab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          label: Text(_tabLabel(tab)),
                          selected: selected,
                          onSelected: (_) => setState(() => _tab = tab),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // ── list ─────────────────────────────────────────────────────
                Expanded(
                  child: summaries.isEmpty
                      ? _EmptyState(query: _query)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xxxl + 56,
                          ),
                          itemCount: summaries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) => _LoanCard(
                            summary: summaries[index],
                            onTap: () =>
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.loanDetail,
                                  arguments: summaries[index].loan.id,
                                ).then(
                                  (_) => context.read<LoanListBloc>().add(
                                    LoadLoansEvent(),
                                  ),
                                ),
                            onDelete: () => _confirmDelete(
                              context,
                              summaries[index].loan.id,
                              summaries[index].loan.borrowerName,
                            ),
                          ),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _tabLabel(_FilterTab tab) => switch (tab) {
    _FilterTab.all => 'loan.filter_all'.tr,
    _FilterTab.active => 'loan.filter_active'.tr,
    _FilterTab.settled => 'loan.filter_settled'.tr,
  };

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('loan.delete_title'.tr),
        content: Text('loan.delete_confirm'.trWith({'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LoanListBloc>().add(DeleteLoanEvent(id));
            },
            child: Text(
              'general.delete'.tr,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLoanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddLoanSheet(
        onAdd:
            (borrowerName, principal, loanDate, dueDate, sourceSavingId, note) {
              context.read<LoanListBloc>().add(
                AddLoanEvent(
                  borrowerName: borrowerName,
                  principalAmount: principal,
                  loanDate: loanDate,
                  dueDate: dueDate,
                  sourceSavingId: sourceSavingId,
                  note: note,
                ),
              );
            },
      ),
    );
  }
}

// ── summary bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int activeCount;
  final double totalOutstanding;

  const _SummaryBar({
    required this.activeCount,
    required this.totalOutstanding,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BarStat(
              label: 'loan.filter_active'.tr,
              value: '$activeCount',
              icon: Icons.people_alt_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: cs.onPrimaryContainer.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: _BarStat(
                label: 'home.loans_total_outstanding'.tr,
                value: _currFmt.format(totalOutstanding),
                icon: Icons.account_balance_wallet_outlined,
                valueColor: totalOutstanding > 0 ? cs.error : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _BarStat({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: cs.onPrimaryContainer.withValues(alpha: 0.7),
        ),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? cs.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── loan card ─────────────────────────────────────────────────────────────────

class _LoanCard extends StatelessWidget {
  final LoanSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LoanCard({
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loan = summary.loan;
    final isSettled = loan.status == 'settled';
    final urgency = _urgency(loan.dueDate);
    final paidPct = loan.principalAmount > 0
        ? ((loan.principalAmount - summary.outstanding) / loan.principalAmount)
              .clamp(0.0, 1.0)
        : 1.0;

    final urgencyColor = _urgencyColor(context, urgency);

    // left accent bar color
    Color accentColor;
    if (isSettled) {
      accentColor = cs.primary;
    } else if (urgency == _DueUrgency.overdue) {
      accentColor = cs.error;
    } else if (urgency == _DueUrgency.soon) {
      accentColor = Colors.orange;
    } else if (urgency == _DueUrgency.upcoming) {
      accentColor = Colors.amber.shade700;
    } else {
      accentColor = cs.primaryContainer;
    }

    return GestureDetector(
      onLongPress: onDelete,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border(left: BorderSide(color: accentColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── row 1: name + badge ──────────────────────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      child: Text(
                        loan.borrowerName.isNotEmpty
                            ? loan.borrowerName[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.borrowerName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'loan.label_loaned'.trWith({
                              'date': _dateFmt.format(loan.loanDate),
                            }),
                            style: AppTextStyles.caption.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
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
                const SizedBox(height: AppSpacing.md),
                // ── row 2: amounts ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _AmountChip(
                        label: 'loan.label_principal'.tr,
                        value: _currFmt.format(loan.principalAmount),
                      ),
                    ),
                    Expanded(
                      child: _AmountChip(
                        label: 'loan.label_outstanding'.tr,
                        value: _currFmt.format(summary.outstanding),
                        valueColor: summary.outstanding > 0
                            ? cs.error
                            : cs.primary,
                      ),
                    ),
                  ],
                ),
                // ── progress bar ─────────────────────────────────────────────
                if (!isSettled) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: paidPct,
                            minHeight: 5,
                            backgroundColor: cs.onSurface.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${(paidPct * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                // ── due date pill ────────────────────────────────────────────
                if (loan.dueDate != null && !isSettled) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _DuePill(
                    dueDate: loan.dueDate!,
                    urgency: urgency,
                    urgencyColor: urgencyColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _AmountChip({
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
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
        ),
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

class _DuePill extends StatelessWidget {
  final DateTime dueDate;
  final _DueUrgency urgency;
  final Color urgencyColor;

  const _DuePill({
    required this.dueDate,
    required this.urgency,
    required this.urgencyColor,
  });

  @override
  Widget build(BuildContext context) {
    final days = dueDate.difference(DateTime.now()).inDays;
    final label = urgency == _DueUrgency.overdue
        ? 'loan.due_overdue'.trWith({'days': (-days).toString()})
        : urgency == _DueUrgency.soon
        ? 'loan.due_soon'.trWith({'days': days.toString()})
        : 'loan.due_in'.trWith({'date': _dateFmt.format(dueDate)});

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: urgencyColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_urgencyIcon(urgency), size: 12, color: urgencyColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: urgencyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            query.isNotEmpty ? Icons.search_off : Icons.handshake_outlined,
            size: 56,
            color: cs.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            query.isNotEmpty ? 'loan.search_empty'.tr : 'loan.empty'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── add loan sheet ────────────────────────────────────────────────────────────

class _AddLoanSheet extends StatefulWidget {
  final void Function(
    String borrowerName,
    double principalAmount,
    DateTime loanDate,
    DateTime? dueDate,
    String sourceSavingId,
    String? note,
  )
  onAdd;

  const _AddLoanSheet({required this.onAdd});

  @override
  State<_AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends State<_AddLoanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _loanDate = DateTime.now();
  DateTime? _dueDate;
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
              // handle
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
              Text('loan.add'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _borrowerCtrl,
                label: 'loan.field_borrower'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountCtrl,
                label: 'loan.field_amount'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'general.must_be_positive'.tr;
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              FormField<FormAccountItem>(
                validator: (_) =>
                    _selectedSaving == null ? 'general.required'.tr : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormAccountSelector(
                      label: 'loan.field_source'.tr,
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
              _DatePickerTile(
                label: _dateFmt.format(_loanDate),
                icon: Icons.calendar_today_outlined,
                prefix: 'loan.field_loan_date_prefix'.tr,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _loanDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _loanDate = picked);
                },
              ),
              _DatePickerTile(
                label: _dueDate != null
                    ? _dateFmt.format(_dueDate!)
                    : 'loan.field_due_date_empty'.tr,
                icon: Icons.event_outlined,
                prefix: 'loan.field_due_date_prefix'.tr,
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _dueDate = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    : null,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'loan.btn_add'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _borrowerCtrl.text.trim(),
                      double.parse(_amountCtrl.text),
                      _loanDate,
                      _dueDate,
                      _selectedSaving!.id,
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

// ── shared date picker tile ───────────────────────────────────────────────────

class _DatePickerTile extends StatelessWidget {
  final String prefix;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DatePickerTile({
    required this.prefix,
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$prefix: ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
