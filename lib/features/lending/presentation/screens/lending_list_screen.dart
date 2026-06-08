import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/lending/presentation/bloc/lending_list_bloc.dart';
import 'package:wise_spends/features/lending/presentation/bloc/lending_list_event.dart';
import 'package:wise_spends/features/lending/presentation/bloc/lending_list_state.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

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

enum _FilterTab { all, active, settled }

class LendingListScreen extends StatelessWidget {
  const LendingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getLendingRepository();
    return BlocProvider(
      create: (_) => LendingListBloc(repo)..add(LoadLendingsEvent()),
      child: const _LendingListContent(),
    );
  }
}

class _LendingListContent extends StatefulWidget {
  const _LendingListContent();

  @override
  State<_LendingListContent> createState() => _LendingListContentState();
}

class _LendingListContentState extends State<_LendingListContent> {
  final _searchCtrl = TextEditingController();
  _FilterTab _tab = _FilterTab.all;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<LendingSummary> _filter(List<LendingSummary> all) {
    return all.where((s) {
      final matchesTab = switch (_tab) {
        _FilterTab.all => true,
        _FilterTab.active => s.lending.status == 'active',
        _FilterTab.settled => s.lending.status == 'settled',
      };
      final matchesSearch =
          _query.isEmpty ||
          s.lending.borrowerName.toLowerCase().contains(_query.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Lendings'), centerTitle: false),
      drawer: const NavigationSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLendingSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Lending'),
      ),
      body: BlocBuilder<LendingListBloc, LendingListState>(
        builder: (context, state) {
          if (state is LendingListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LendingError) {
            return Center(child: Text(state.message));
          }
          if (state is LendingListLoaded) {
            final summaries = _filter(state.summaries);
            final activeCount = state.summaries
                .where((s) => s.lending.status == 'active')
                .length;
            final totalOutstanding = state.summaries
                .where((s) => s.lending.status == 'active')
                .fold(0.0, (sum, s) => sum + s.outstanding);

            return Column(
              children: [
                if (state.summaries.isNotEmpty)
                  _SummaryBar(
                    activeCount: activeCount,
                    totalOutstanding: totalOutstanding,
                  ),
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
                      hintText: 'Search borrower...',
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
                          itemBuilder: (context, index) => _LendingCard(
                            summary: summaries[index],
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.lendingDetail,
                              arguments: summaries[index].lending.id,
                            ).then(
                              (_) => context.read<LendingListBloc>().add(
                                LoadLendingsEvent(),
                              ),
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              summaries[index].lending.id,
                              summaries[index].lending.borrowerName,
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
    _FilterTab.all => 'All',
    _FilterTab.active => 'Active',
    _FilterTab.settled => 'Settled',
  };

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lending'),
        content: Text('Delete lending record for "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LendingListBloc>().add(DeleteLendingEvent(id));
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLendingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddLendingSheet(
        onAdd: (
          borrowerName,
          principal,
          lendingDate,
          dueDate,
          sourceSavingId,
          note,
          noAutoDeduct,
        ) {
          context.read<LendingListBloc>().add(
            AddLendingEvent(
              borrowerName: borrowerName,
              principalAmount: principal,
              lendingDate: lendingDate,
              dueDate: dueDate,
              sourceSavingId: sourceSavingId,
              note: note,
              noAutoDeduct: noAutoDeduct,
            ),
          );
        },
      ),
    );
  }
}

// ── Summary bar ────────────────────────────────────────────────────────────────

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
              label: 'Active',
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
                label: 'Total Receivable',
                value: _currFmt.format(totalOutstanding),
                icon: Icons.account_balance_wallet_outlined,
                valueColor: totalOutstanding > 0 ? cs.primary : null,
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
        Icon(icon, size: 18, color: cs.onPrimaryContainer.withValues(alpha: 0.7)),
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

// ── Lending card ───────────────────────────────────────────────────────────────

class _LendingCard extends StatelessWidget {
  final LendingSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LendingCard({
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lending = summary.lending;
    final isSettled = lending.status == 'settled';
    final urgency = _urgency(lending.dueDate);
    final paidPct = lending.principalAmount > 0
        ? ((lending.principalAmount - summary.outstanding) /
              lending.principalAmount)
              .clamp(0.0, 1.0)
        : 1.0;

    final urgencyColor = _urgencyColor(context, urgency);
    Color accentColor;
    if (isSettled) {
      accentColor = cs.primary;
    } else if (urgency == _DueUrgency.overdue) {
      accentColor = cs.error;
    } else if (urgency == _DueUrgency.soon) {
      accentColor = Colors.orange;
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      child: Text(
                        lending.borrowerName.isNotEmpty
                            ? lending.borrowerName[0].toUpperCase()
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
                            lending.borrowerName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Lent on ${_dateFmt.format(lending.lendingDate)}',
                            style: AppTextStyles.caption.copyWith(
                              color: cs.onSurfaceVariant,
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _AmountChip(
                        label: 'Lent',
                        value: _currFmt.format(lending.principalAmount),
                      ),
                    ),
                    Expanded(
                      child: _AmountChip(
                        label: 'Receivable',
                        value: _currFmt.format(summary.outstanding),
                        valueColor: summary.outstanding > 0
                            ? cs.primary
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ),
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
                            backgroundColor: cs.onSurface.withValues(alpha: 0.08),
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
                if (lending.dueDate != null && !isSettled) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _DuePill(
                    dueDate: lending.dueDate!,
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

  const _AmountChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant)),
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
        ? 'Overdue by ${(-days)} days'
        : urgency == _DueUrgency.soon
        ? 'Due in $days days'
        : 'Due: ${_dateFmt.format(dueDate)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
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

// ── Empty state ────────────────────────────────────────────────────────────────

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
            query.isNotEmpty
                ? Icons.search_off
                : Icons.volunteer_activism_outlined,
            size: 56,
            color: cs.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            query.isNotEmpty ? 'No results found' : 'No lending records yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add lending sheet ─────────────────────────────────────────────────────────

class _AddLendingSheet extends StatefulWidget {
  final void Function(
    String borrowerName,
    double principalAmount,
    DateTime lendingDate,
    DateTime? dueDate,
    String sourceSavingId,
    String? note,
    bool noAutoDeduct,
  ) onAdd;

  const _AddLendingSheet({required this.onAdd});

  @override
  State<_AddLendingSheet> createState() => _AddLendingSheetState();
}

class _AddLendingSheetState extends State<_AddLendingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _lendingDate = DateTime.now();
  DateTime? _dueDate;
  FormAccountItem? _selectedSaving;
  List<FormAccountItem> _savings = [];
  bool _noAutoDeduct = false;

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
              Text('Add Lending', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _borrowerCtrl,
                label: 'Borrower Name',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
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
              _NoAutoDeductToggle(
                value: _noAutoDeduct,
                onChanged: (v) => setState(() {
                  _noAutoDeduct = v;
                  if (v) _selectedSaving = null;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!_noAutoDeduct)
                FormField<FormAccountItem>(
                  validator: (_) => (!_noAutoDeduct && _selectedSaving == null)
                      ? 'Required'
                      : null,
                  builder: (field) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormAccountSelector(
                        label: 'Source Account (deducted)',
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
                label: _dateFmt.format(_lendingDate),
                icon: Icons.calendar_today_outlined,
                prefix: 'Lending date',
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _lendingDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _lendingDate = picked);
                },
              ),
              _DatePickerTile(
                label: _dueDate != null
                    ? _dateFmt.format(_dueDate!)
                    : 'Not set',
                icon: Icons.event_outlined,
                prefix: 'Expected return date',
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
                label: 'Note (optional)',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'Add Lending',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _borrowerCtrl.text.trim(),
                      double.parse(_amountCtrl.text),
                      _lendingDate,
                      _dueDate,
                      _noAutoDeduct ? '' : _selectedSaving!.id,
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

// ── No-auto-deduct toggle ──────────────────────────────────────────────────────

class _NoAutoDeductToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NoAutoDeductToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: value
            ? cs.secondaryContainer.withValues(alpha: 0.4)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: value
              ? cs.secondary.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.money_off_outlined,
            size: 18,
            color: value ? cs.secondary : cs.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lent from outside app',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: value ? cs.onSecondaryContainer : cs.onSurface,
                  ),
                ),
                Text(
                  'No saving account deducted on creation',
                  style: AppTextStyles.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── Date picker tile ──────────────────────────────────────────────────────────

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
