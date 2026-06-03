import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_detail_bloc.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_detail_event.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_detail_state.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'widgets/credit_card_form_widgets.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');
final _dateFmt = DateFormat('dd MMM yyyy');

class CreditCardDetailScreen extends StatelessWidget {
  final String cardId;
  const CreditCardDetailScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
    return BlocProvider(
      create: (_) => CreditCardDetailBloc(
        locator.getCreditCardRepository(),
        locator.getCreditCardChargeRepository(),
        locator.getCreditCardPaymentRepository(),
      )..add(LoadCreditCardDetailEvent(cardId)),
      child: const _CreditCardDetailContent(),
    );
  }
}

// ── main scaffold ──────────────────────────────────────────────────────────────

class _CreditCardDetailContent extends StatefulWidget {
  const _CreditCardDetailContent();

  @override
  State<_CreditCardDetailContent> createState() =>
      _CreditCardDetailContentState();
}

class _CreditCardDetailContentState extends State<_CreditCardDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreditCardDetailBloc, CreditCardDetailState>(
      listener: (context, state) {
        // 'deleted' is the sentinel value set when deleteCardWithCleanup succeeds
        if (state is CreditCardDetailError && state.message == 'deleted') {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        if (state is CreditCardDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CreditCardDetailError && state.message != 'deleted') {
          return Scaffold(
            appBar: AppBar(title: Text('general.error'.tr)),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is CreditCardDetailLoaded) {
          return Scaffold(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            appBar: AppBar(
              title: Text(state.card.name),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'credit_card.edit'.tr,
                  onPressed: () => _showEditCardSheet(context, state.card),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'general.delete'.tr,
                  onPressed: () => _confirmDeleteCard(context, state),
                ),
              ],
            ),
            body: Column(
              children: [
                _CardHeader(state: state),
                _PeriodSelector(
                  current: state.period,
                  onChanged: (p) => context.read<CreditCardDetailBloc>().add(
                    ChangePeriodEvent(p),
                  ),
                ),
                _CustomTabBar(controller: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ChargesList(
                        charges: state.charges,
                        unpaidAmounts: state.chargeUnpaidAmounts,
                        period: state.period,
                        cardId: state.card.id,
                        onDelete: (id) => context
                            .read<CreditCardDetailBloc>()
                            .add(DeleteChargeEvent(id)),
                        onConfirm: (chargeId) => context
                            .read<CreditCardDetailBloc>()
                            .add(ConfirmChargeEvent(
                                chargeId: chargeId,
                                cardId: state.card.id)),
                      ),
                      _PaymentsList(
                        payments: state.payments,
                        allocations: state.paymentAllocations,
                        period: state.period,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: _DetailFAB(
              onAddCharge: () => _showAddChargeSheet(context, state.card.id),
              // Always pass allCharges to payment sheet so user can pay
              // any unpaid charge regardless of the display period.
              onMakePayment: () => _showAddPaymentSheet(
                context,
                state.card.id,
                state.allCharges,
                unpaidAmounts: state.chargeUnpaidAmounts,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAddChargeSheet(BuildContext context, String cardId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddChargeSheet(
        onAdd: (desc, amount, categoryId, date, note, reservedSavingId,
            status, isRebate) {
          context.read<CreditCardDetailBloc>().add(
            AddChargeEvent(
              creditCardId: cardId,
              description: desc,
              amount: amount,
              categoryId: categoryId,
              chargeDate: date,
              note: note,
              reservedSavingId: reservedSavingId,
              status: status,
              isRebate: isRebate,
            ),
          );
        },
      ),
    );
  }

  void _showAddPaymentSheet(
    BuildContext context,
    String cardId,
    List<CrdCardCharge> charges, {
    required Map<String, double> unpaidAmounts,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddPaymentSheet(
        charges: charges,
        unpaidAmounts: unpaidAmounts,
        onAdd: (amount, sourceSavingId, date, note, allocations, rebateAllocs) {
          context.read<CreditCardDetailBloc>().add(
            AddPaymentEvent(
              creditCardId: cardId,
              sourceSavingId: sourceSavingId,
              amount: amount,
              paymentDate: date,
              note: note,
              chargeAllocations: allocations,
              rebateAllocations: rebateAllocs,
            ),
          );
        },
      ),
    );
  }

  void _showEditCardSheet(BuildContext context, CrdCardCreditCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _CardFormSheet(
        existing: card,
        onSave: (name, last4, limit, stmtDay, dueDay, note) {
          context.read<CreditCardDetailBloc>().add(
            UpdateCreditCardEvent(
              cardId: card.id,
              name: name,
              lastFourDigits: last4,
              creditLimit: limit,
              statementDay: stmtDay,
              dueDay: dueDay,
              note: note,
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteCard(BuildContext context, CreditCardDetailLoaded state) {
    final reservedCharges = state.charges
        .where((c) => c.reservedSavingId != null)
        .toList();
    final unpaidReserved = reservedCharges
        .where((c) => (state.chargeUnpaidAmounts[c.id] ?? 0) > 0)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('credit_card.delete_title'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'credit_card.delete_confirm'.trWith({'name': state.card.name}),
            ),
            if (unpaidReserved.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          size: 14,
                          color: Theme.of(ctx).colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'credit_card.delete_reserved_warning'.trWith({
                              'count': unpaidReserved.length.toString(),
                            }),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(ctx).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...unpaidReserved.map(
                      (c) => Text(
                        '• ${c.description}  (${_currFmt.format(state.chargeUnpaidAmounts[c.id] ?? 0)} unpaid)',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(ctx).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'credit_card.delete_reserved_note'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(
                          ctx,
                        ).colorScheme.onErrorContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CreditCardDetailBloc>().add(
                DeleteCreditCardDetailEvent(state.card.id),
              );
            },
            child: Text('general.delete'.tr),
          ),
        ],
      ),
    );
  }
}

// ── animated FAB ───────────────────────────────────────────────────────────────

class _DetailFAB extends StatefulWidget {
  final VoidCallback onAddCharge;
  final VoidCallback onMakePayment;

  const _DetailFAB({required this.onAddCharge, required this.onMakePayment});

  @override
  State<_DetailFAB> createState() => _DetailFABState();
}

class _DetailFABState extends State<_DetailFAB>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _anim.forward() : _anim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ScaleTransition(
          scale: _scale,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniAction(
                icon: Icons.receipt_long_rounded,
                label: 'credit_card.add_charge'.tr,
                color: cs.secondaryContainer,
                iconColor: cs.onSecondaryContainer,
                onTap: () {
                  _toggle();
                  widget.onAddCharge();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _MiniAction(
                icon: Icons.payments_rounded,
                label: 'credit_card.make_payment'.tr,
                color: cs.primaryContainer,
                iconColor: cs.onPrimaryContainer,
                onTap: () {
                  _toggle();
                  widget.onMakePayment();
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _expanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── card header ────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final CreditCardDetailLoaded state;
  const _CardHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final card = state.card;
    final available = (card.creditLimit - state.totalDebt).clamp(
      0.0,
      double.infinity,
    );
    final usedPct = card.creditLimit > 0
        ? (state.totalDebt / card.creditLimit).clamp(0.0, 1.0)
        : 0.0;
    final barColor = usedPct > 0.8
        ? cs.error
        : usedPct > 0.5
        ? cs.tertiary
        : cs.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.secondaryContainer,
            cs.secondaryContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card_rounded,
                size: 18,
                color: cs.onSecondaryContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  card.lastFourDigits != null
                      ? '${card.name}  •••• ${card.lastFourDigits}'
                      : card.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoStat(
                  label: 'credit_card.label_limit'.tr,
                  value: _currFmt.format(card.creditLimit),
                ),
              ),
              Expanded(
                child: _InfoStat(
                  label: 'credit_card.label_debt'.tr,
                  value: _currFmt.format(state.totalDebt),
                  valueColor: state.totalDebt > 0 ? cs.error : null,
                ),
              ),
              Expanded(
                child: _InfoStat(
                  label: 'credit_card.label_available'.tr,
                  value: _currFmt.format(available),
                  valueColor: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: usedPct,
              minHeight: 6,
              backgroundColor: cs.surface.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'credit_card.statement_due'.trWith({
              'stmt': card.statementDay.toString(),
              'due': card.dueDay.toString(),
            }),
            style: AppTextStyles.caption.copyWith(
              color: cs.onSecondaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: cs.onSecondaryContainer.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}

// ── custom tab bar ─────────────────────────────────────────────────────────────

class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  const _CustomTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: cs.onPrimary,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: 'credit_card.tab_charges'.tr),
          Tab(text: 'credit_card.tab_payments'.tr),
        ],
      ),
    );
  }
}

// ── charges filter enum ────────────────────────────────────────────────────────

enum _ChargeFilter { all, unpaid, pending, paid, rebate }

// ── charges list ───────────────────────────────────────────────────────────────

class _ChargesList extends StatefulWidget {
  final List<CrdCardCharge> charges;
  final Map<String, double> unpaidAmounts;
  final ChargePeriod period;
  final String cardId;
  final void Function(String id) onDelete;
  final void Function(String chargeId) onConfirm;

  const _ChargesList({
    required this.charges,
    required this.unpaidAmounts,
    required this.period,
    required this.cardId,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  State<_ChargesList> createState() => _ChargesListState();
}

class _ChargesListState extends State<_ChargesList> {
  _ChargeFilter _filter = _ChargeFilter.all;

  List<CrdCardCharge> get _filtered {
    return widget.charges.where((c) {
      final unpaid = widget.unpaidAmounts[c.id] ?? c.amount;
      return switch (_filter) {
        _ChargeFilter.all => true,
        _ChargeFilter.unpaid => !c.isRebate && unpaid > 0,
        _ChargeFilter.pending => c.status == 'pending',
        _ChargeFilter.paid => !c.isRebate && unpaid <= 0,
        _ChargeFilter.rebate => c.isRebate,
      };
    }).toList();
  }

  String _filterLabel(_ChargeFilter f) => switch (f) {
    _ChargeFilter.all => 'credit_card.filter_all'.tr,
    _ChargeFilter.unpaid => 'credit_card.filter_unpaid'.tr,
    _ChargeFilter.pending => 'credit_card.filter_pending'.tr,
    _ChargeFilter.paid => 'credit_card.filter_paid'.tr,
    _ChargeFilter.rebate => 'credit_card.filter_rebate'.tr,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final visible = _filtered;

    return Column(
      children: [
        // ── filter chips ────────────────────────────────────────────────────
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: _ChargeFilter.values.map((f) {
              final selected = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: FilterChip(
                  label: Text(_filterLabel(f)),
                  selected: selected,
                  onSelected: (_) => setState(() => _filter = f),
                  visualDensity: VisualDensity.compact,
                  selectedColor: cs.primaryContainer,
                  checkmarkColor: cs.primary,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // ── list ────────────────────────────────────────────────────────────
        Expanded(
          child: visible.isEmpty
              ? _EmptyTabState(
                  icon: Icons.receipt_long_outlined,
                  message: _filter == _ChargeFilter.all
                      ? 'credit_card.charges_empty'.tr
                      : 'credit_card.charges_empty_filter'.tr,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxxl + 72,
                  ),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final charge = visible[index];
                    return _ChargeTile(
                      charge: charge,
                      unpaidAmount: widget.unpaidAmounts[charge.id] ?? charge.amount,
                      onDelete: () => widget.onDelete(charge.id),
                      onConfirm: charge.status == 'pending'
                          ? () => widget.onConfirm(charge.id)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ChargeTile extends StatelessWidget {
  final CrdCardCharge charge;
  final double unpaidAmount;
  final VoidCallback onDelete;
  /// Non-null only when status == 'pending'. Promotes to 'posted'.
  final VoidCallback? onConfirm;

  const _ChargeTile({
    required this.charge,
    required this.unpaidAmount,
    required this.onDelete,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRebate = charge.isRebate;
    final isPending = charge.status == 'pending';
    final isReserved = charge.reservedSavingId != null && !isRebate;
    final isPartiallyPaid =
        !isRebate && unpaidAmount < charge.amount && unpaidAmount > 0;
    final isFullyPaid = !isRebate && unpaidAmount <= 0;

    // accent / icon colours
    final Color accentColor;
    final Color iconBg;
    final Color iconColor;
    final IconData iconData;

    if (isRebate) {
      accentColor = Colors.green.shade600;
      iconBg = Colors.green.shade50;
      iconColor = Colors.green.shade700;
      iconData = Icons.card_giftcard_rounded;
    } else if (isPending) {
      accentColor = Colors.amber.shade700;
      iconBg = Colors.amber.shade50;
      iconColor = Colors.amber.shade800;
      iconData = Icons.hourglass_empty_rounded;
    } else if (isFullyPaid) {
      accentColor = cs.primary;
      iconBg = cs.primaryContainer.withValues(alpha: 0.5);
      iconColor = cs.primary;
      iconData = Icons.check_circle_rounded;
    } else if (isReserved) {
      accentColor = cs.primary;
      iconBg = cs.primaryContainer.withValues(alpha: 0.5);
      iconColor = cs.primary;
      iconData = Icons.savings_outlined;
    } else {
      accentColor = cs.outlineVariant;
      iconBg = cs.secondaryContainer.withValues(alpha: 0.5);
      iconColor = cs.secondary;
      iconData = Icons.receipt_outlined;
    }

    return Dismissible(
      key: Key(charge.id),
      // Pending charges: swipe right = confirm, swipe left = delete.
      // Others: swipe left = delete only.
      direction: isPending
          ? DismissDirection.horizontal
          : DismissDirection.endToStart,
      // Background (swipe right) — confirm action for pending
      background: isPending
          ? Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade700),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'credit_card.confirm_charge'.tr,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
      // Secondary background (swipe left) — delete
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(Icons.delete_outline_rounded, color: cs.error),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && isPending) {
          // Confirm the pending charge — no dialog needed
          onConfirm?.call();
          return false; // keep in list; BLoC reload will re-render as posted
        }
        // Delete
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('credit_card.delete_title'.tr),
                content: Text(
                  'credit_card.delete_charge_confirm'.trWith({
                    'name': charge.description,
                  }),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('general.cancel'.tr),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: cs.error),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('general.delete'.tr),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Opacity(
        opacity: isFullyPaid ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border(
              left: BorderSide(color: accentColor, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(iconData, size: 18, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              charge.description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isPending)
                            _StatusBadge(
                              label: 'credit_card.status_pending'.tr,
                              color: Colors.amber.shade700,
                            ),
                          if (isRebate)
                            _StatusBadge(
                              label: 'credit_card.status_rebate'.tr,
                              color: Colors.green.shade700,
                            ),
                        ],
                      ),
                      Text(
                        _dateFmt.format(charge.chargeDate),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (isReserved) ...[
                        const SizedBox(height: 3),
                        _ReservationBadge(savingId: charge.reservedSavingId!),
                      ],
                      if (isPending && onConfirm != null) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: onConfirm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                  color: Colors.green.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded,
                                    size: 11,
                                    color: Colors.green.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  'credit_card.confirm_charge'.tr,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Amount column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isRebate)
                      Text(
                        '+ ${_currFmt.format(charge.amount)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      )
                    else if (isFullyPaid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'credit_card.paid'.tr,
                          style: AppTextStyles.caption.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else ...[
                      Text(
                        _currFmt.format(unpaidAmount),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isPending
                              ? Colors.amber.shade800
                              : cs.secondary,
                        ),
                      ),
                      if (isPartiallyPaid)
                        Text(
                          'of ${_currFmt.format(charge.amount)}',
                          style: AppTextStyles.caption.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ── charge type toggle button ──────────────────────────────────────────────────

class _TypeToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggleBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── reservation badge ──────────────────────────────────────────────────────────

class _ReservationBadge extends StatefulWidget {
  final String savingId;
  const _ReservationBadge({required this.savingId});

  @override
  State<_ReservationBadge> createState() => _ReservationBadgeState();
}

class _ReservationBadgeState extends State<_ReservationBadge> {
  String? _savingName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getSavingRepository();
      final saving = await repo.getSavingById(widget.savingId);
      if (mounted) setState(() => _savingName = saving?.saving.name);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = _savingName != null
        ? 'credit_card.reserved_from'.trWith({'name': _savingName!})
        : 'credit_card.reserved'.tr;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.savings_outlined, size: 10, color: cs.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: cs.primary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── payments list ──────────────────────────────────────────────────────────────
class _PaymentsList extends StatelessWidget {
  final List<CrdCardPayment> payments;
  final Map<String, List<PaymentAllocationDetail>> allocations;
  final ChargePeriod period;

  const _PaymentsList({
    required this.payments,
    required this.allocations,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return _EmptyTabState(
        icon: Icons.payments_outlined,
        message: 'credit_card.payments_empty'.tr,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxxl + 72,
      ),
      itemCount: payments.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final payment = payments[payments.length - 1 - index];
        return _PaymentTile(
          payment: payment,
          allocationDetails: allocations[payment.id] ?? [],
        );
      },
    );
  }
}

class _PaymentTile extends StatefulWidget {
  final CrdCardPayment payment;
  final List<PaymentAllocationDetail> allocationDetails;

  const _PaymentTile({required this.payment, required this.allocationDetails});

  @override
  State<_PaymentTile> createState() => _PaymentTileState();
}

class _PaymentTileState extends State<_PaymentTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasDetails = widget.allocationDetails.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border(left: BorderSide(color: cs.primary, width: 3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasDetails
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.payments_rounded,
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
                          _dateFmt.format(widget.payment.paymentDate),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.payment.note != null)
                          Text(
                            widget.payment.note!,
                            style: AppTextStyles.caption.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        if (hasDetails)
                          Text(
                            '${widget.allocationDetails.length} ${'credit_card.charges_covered'.tr}',
                            style: AppTextStyles.caption.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currFmt.format(widget.payment.amount),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                      if (hasDetails)
                        Icon(
                          _expanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded allocation breakdown
          if (_expanded && hasDetails)
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'credit_card.payment_breakdown'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...widget.allocationDetails.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 13,
                            color: cs.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              d.chargeDescription,
                              style: AppTextStyles.caption,
                            ),
                          ),
                          Text(
                            _currFmt.format(d.allocatedAmount),
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── empty tab ──────────────────────────────────────────────────────────────────

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyTabState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: cs.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── card form sheet (add & edit) ───────────────────────────────────────────────

class _CardFormSheet extends StatefulWidget {
  final CrdCardCreditCard? existing; // null = add, non-null = edit
  final void Function(
    String name,
    String? lastFourDigits,
    double creditLimit,
    int statementDay,
    int dueDay,
    String? note,
  )
  onSave;

  const _CardFormSheet({this.existing, required this.onSave});

  @override
  State<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<_CardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _last4Ctrl;
  late final TextEditingController _limitCtrl;
  late final TextEditingController _noteCtrl;
  late int _statementDay;
  late int _dueDay;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _last4Ctrl = TextEditingController(text: e?.lastFourDigits ?? '');
    _limitCtrl = TextEditingController(
      text: e != null ? e.creditLimit.toString() : '',
    );
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _statementDay = e?.statementDay ?? 1;
    _dueDay = e?.dueDay ?? 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _last4Ctrl.dispose();
    _limitCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;
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
              CcDragHandle(),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_rounded : Icons.add_card_rounded,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    isEdit ? 'credit_card.edit'.tr : 'credit_card.add'.tr,
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Card name
              AppTextField(
                controller: _nameCtrl,
                label: 'credit_card.field_name'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Last 4 digits — digits only, max 4
              TextFormField(
                controller: _last4Ctrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'credit_card.field_last4'.tr,
                  counterText: '',
                  border: const OutlineInputBorder(),
                  prefixText: '•••• ',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Credit limit
              AppTextField(
                controller: _limitCtrl,
                label: 'credit_card.field_limit'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'general.required'.tr;
                  if (double.tryParse(v) == null) {
                    return 'general.invalid_number'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Statement day picker
              CcDayPickerField(
                label: 'credit_card.field_statement_day'.tr,
                hint: 'credit_card.statement_day_hint'.tr,
                value: _statementDay,
                onChanged: (d) => setState(() => _statementDay = d),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Due day picker
              CcDayPickerField(
                label: 'credit_card.field_due_day'.tr,
                hint: 'credit_card.due_day_hint'.tr,
                value: _dueDay,
                onChanged: (d) => setState(() => _dueDay = d),
              ),

              // Billing cycle preview
              CcBillingCyclePreview(
                statementDay: _statementDay,
                dueDay: _dueDay,
              ),
              const SizedBox(height: AppSpacing.sm),

              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: isEdit ? 'general.save'.tr : 'credit_card.btn_add'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(
                      _nameCtrl.text.trim(),
                      _last4Ctrl.text.trim().isEmpty
                          ? null
                          : _last4Ctrl.text.trim(),
                      double.parse(_limitCtrl.text),
                      _statementDay,
                      _dueDay,
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

// ── billing cycle preview ──────────────────────────────────────────────────────

// ── add charge sheet ───────────────────────────────────────────────────────────

class _AddChargeSheet extends StatefulWidget {
  final void Function(
    String description,
    double amount,
    String? categoryId,
    DateTime chargeDate,
    String? note,
    String? reservedSavingId,
    String status,
    bool isRebate,
  )
  onAdd;

  const _AddChargeSheet({required this.onAdd});

  @override
  State<_AddChargeSheet> createState() => _AddChargeSheetState();
}

class _AddChargeSheetState extends State<_AddChargeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _chargeDate = DateTime.now();
  bool _reserveEnabled = false;
  FormAccountItem? _reservedSaving;
  List<FormAccountItem> _savings = [];
  bool _isRebate = false;
  bool _isPending = false;

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
    _descCtrl.dispose();
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
              CcDragHandle(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _isRebate
                          ? Colors.green.shade50
                          : cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      _isRebate
                          ? Icons.card_giftcard_rounded
                          : Icons.receipt_long_rounded,
                      color: _isRebate
                          ? Colors.green.shade700
                          : cs.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _isRebate
                        ? 'credit_card.add_rebate'.tr
                        : 'credit_card.add_charge'.tr,
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── charge type toggle ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _TypeToggleBtn(
                      label: 'credit_card.type_charge'.tr,
                      icon: Icons.receipt_long_rounded,
                      selected: !_isRebate,
                      color: cs.secondary,
                      onTap: () => setState(() {
                        _isRebate = false;
                        _reserveEnabled = false;
                        _reservedSaving = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TypeToggleBtn(
                      label: 'credit_card.type_rebate'.tr,
                      icon: Icons.card_giftcard_rounded,
                      selected: _isRebate,
                      color: Colors.green.shade700,
                      onTap: () => setState(() {
                        _isRebate = true;
                        _isPending = false;
                        _reserveEnabled = false;
                        _reservedSaving = null;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: _isRebate
                    ? 'credit_card.rebate_description'.tr
                    : 'credit_card.charge_description'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _amountCtrl,
                label: 'credit_card.charge_amount'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'general.must_be_positive'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _DatePickerTile(
                label: 'credit_card.charge_date_prefix'.tr,
                date: _chargeDate,
                onPicked: (d) => setState(() => _chargeDate = d),
              ),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── pending toggle (only for regular charges) ──────────────────
              if (!_isRebate)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _isPending
                        ? Colors.amber.shade50
                        : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _isPending
                          ? Colors.amber.shade400
                          : cs.outlineVariant,
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    secondary: Icon(
                      Icons.hourglass_empty_rounded,
                      color: _isPending
                          ? Colors.amber.shade700
                          : cs.onSurfaceVariant,
                    ),
                    title: Text(
                      'credit_card.pending_toggle'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'credit_card.pending_hint'.tr,
                      style: AppTextStyles.caption
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                    value: _isPending,
                    onChanged: (v) => setState(() => _isPending = v),
                  ),
                ),

              // ── reserve toggle (only for regular charges) ──────────────────
              if (!_isRebate)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _reserveEnabled
                        ? cs.primaryContainer.withValues(alpha: 0.3)
                        : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _reserveEnabled
                          ? cs.primary.withValues(alpha: 0.4)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        title: Text(
                          'credit_card.reserve_toggle'.tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'credit_card.reserve_hint'.tr,
                          style: AppTextStyles.caption.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        secondary: Icon(
                          Icons.savings_outlined,
                          color: _reserveEnabled
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                        value: _reserveEnabled,
                        onChanged: (v) => setState(() {
                          _reserveEnabled = v;
                          if (!v) _reservedSaving = null;
                        }),
                      ),
                      if (_reserveEnabled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          child: FormField<FormAccountItem>(
                            validator: (_) =>
                                _reserveEnabled && _reservedSaving == null
                                ? 'general.required'.tr
                                : null,
                            builder: (field) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FormAccountSelector(
                                  label: 'credit_card.reserve_account'.tr,
                                  selectedAccount: _reservedSaving,
                                  accounts: _savings,
                                  onAccountSelected: (a) =>
                                      setState(() => _reservedSaving = a),
                                ),
                                if (field.errorText != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      left: 12,
                                    ),
                                    child: Text(
                                      field.errorText!,
                                      style: TextStyle(
                                        color: cs.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: _isRebate
                    ? 'credit_card.rebate_btn'.tr
                    : 'credit_card.charge_btn'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _descCtrl.text.trim(),
                      double.parse(_amountCtrl.text),
                      null,
                      _chargeDate,
                      _noteCtrl.text.trim().isEmpty
                          ? null
                          : _noteCtrl.text.trim(),
                      (!_isRebate && _reserveEnabled) ? _reservedSaving?.id : null,
                      _isPending ? 'pending' : 'posted',
                      _isRebate,
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

// ── add payment sheet ──────────────────────────────────────────────────────────

class _AddPaymentSheet extends StatefulWidget {
  final List<CrdCardCharge> charges;
  final Map<String, double> unpaidAmounts;
  final void Function(
    double amount,
    String sourceSavingId,
    DateTime paymentDate,
    String? note,
    List<({String chargeId, double amount})>? chargeAllocations,
    List<({String chargeId, double amount})>? rebateAllocations,
  )
  onAdd;

  const _AddPaymentSheet({
    required this.charges,
    required this.unpaidAmounts,
    required this.onAdd,
  });

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  /// selected chargeId → overridden amount (null = use full unpaid amount)
  final Map<String, double?> _selected = {};

  /// Rebate charge IDs whose credit is applied toward this payment.
  final Set<String> _appliedRebateIds = {};

  FormAccountItem? _sourceSaving;
  List<FormAccountItem> _savings = [];

  @override
  void initState() {
    super.initState();
    _loadSavings();
    // Default: all rebates applied.
    for (final r in _rebates) {
      _appliedRebateIds.add(r.id);
    }
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
    _noteCtrl.dispose();
    super.dispose();
  }

  double _unpaidFor(CrdCardCharge c) => widget.unpaidAmounts[c.id] ?? c.amount;

  double _payAmountFor(CrdCardCharge c) => _selected[c.id] ?? _unpaidFor(c);

  double get _totalSelected => _activeCharges.fold(
    0.0,
    (s, c) => s + (_selected.keys.contains(c.id) ? _payAmountFor(c) : .0),
  );

  /// Rebate charges (isRebate = true) — shown as available credits.
  List<CrdCardCharge> get _rebates =>
      widget.charges.where((c) => c.isRebate).toList();

  /// Sum of currently-toggled rebate credits.
  double get _appliedCredits => _rebates
      .where((c) => _appliedRebateIds.contains(c.id))
      .fold(0.0, (s, c) => s + c.amount.abs());

  /// Net cash that must come from the user's saving account.
  double get _netPayable =>
      (_totalSelected - _appliedCredits).clamp(0.0, double.infinity);

  /// Whether a source saving is required (net cash > 0 and any selected
  /// charge is not fully covered by reserved savings).
  bool get _needsSourceSaving {
    if (_netPayable <= 0) return false;
    // If all selected charges are reserved, their savings are used automatically.
    return _activeCharges.any(
      (c) => _selected.containsKey(c.id) && c.reservedSavingId == null,
    );
  }

  bool get _allSelected =>
      _activeCharges.isNotEmpty &&
      _activeCharges.every((c) => _selected.containsKey(c.id));

  /// Only non-rebate charges with unpaid amount > 0
  List<CrdCardCharge> get _activeCharges =>
      widget.charges.where((c) => !c.isRebate && _unpaidFor(c) > 0).toList();

  // ── Allocation builders ────────────────────────────────────────────────────

  /// Distributes applied credits proportionally across selected charges.
  List<({String chargeId, double amount})> _buildRebateAllocations() {
    final credits = _appliedCredits;
    if (credits <= 0) return [];
    final selected =
        _activeCharges.where((c) => _selected.containsKey(c.id)).toList();
    final total = _totalSelected;
    if (total <= 0) return [];

    var remaining = credits;
    final result = <({String chargeId, double amount})>[];
    for (final c in selected) {
      if (remaining <= 0) break;
      final chargeAmt = _payAmountFor(c);
      final share = (credits * chargeAmt / total).clamp(0.0, chargeAmt);
      final actual = share.clamp(0.0, remaining);
      if (actual > 0.001) {
        result.add((chargeId: c.id, amount: double.parse(actual.toStringAsFixed(2))));
        remaining -= actual;
      }
    }
    return result;
  }

  List<({String chargeId, double amount})> _buildCashAllocations() {
    final rebateMap = {
      for (final r in _buildRebateAllocations()) r.chargeId: r.amount
    };
    return _activeCharges
        .where((c) => _selected.containsKey(c.id))
        .map((c) {
          final cash = _payAmountFor(c) - (rebateMap[c.id] ?? 0.0);
          return (chargeId: c.id, amount: double.parse(cash.toStringAsFixed(2)));
        })
        .where((a) => a.amount > 0.001)
        .toList();
  }

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selected.clear();
      } else {
        for (final c in _activeCharges) {
          _selected.putIfAbsent(c.id, () => null);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reserved = _activeCharges
        .where((c) => c.reservedSavingId != null)
        .toList();
    final free = _activeCharges
        .where((c) => c.reservedSavingId == null)
        .toList();

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
              CcDragHandle(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.payments_rounded,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('credit_card.make_payment'.tr, style: AppTextStyles.h3),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              if (_activeCharges.isEmpty) ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 40,
                        color: cs.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'credit_card.all_paid'.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Select / Deselect all
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'credit_card.select_charges'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _toggleAll,
                      icon: Icon(
                        _allSelected
                            ? Icons.deselect_rounded
                            : Icons.select_all_rounded,
                        size: 16,
                      ),
                      label: Text(
                        _allSelected
                            ? 'credit_card.deselect_all'.tr
                            : 'credit_card.select_all'.tr,
                        style: AppTextStyles.labelMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Reserved charges
                if (reserved.isNotEmpty) ...[
                  _SectionLabel(
                    icon: Icons.savings_outlined,
                    label: 'credit_card.reserved_charges_title'.tr,
                    color: cs.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...reserved.map(
                    (c) => _ChargeSelectTile(
                      charge: c,
                      unpaidAmount: _unpaidFor(c),
                      payAmount: _payAmountFor(c),
                      isSelected: _selected.containsKey(c.id),
                      onToggle: (v) => setState(() {
                        if (v) {
                          _selected[c.id] = null;
                        } else {
                          _selected.remove(c.id);
                        }
                      }),
                      onAmountEdit: (a) => setState(() => _selected[c.id] = a),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // Free charges
                if (free.isNotEmpty) ...[
                  _SectionLabel(
                    icon: Icons.receipt_outlined,
                    label: 'credit_card.free_charges_title'.tr,
                    color: cs.secondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...free.map(
                    (c) => _ChargeSelectTile(
                      charge: c,
                      unpaidAmount: _unpaidFor(c),
                      payAmount: _payAmountFor(c),
                      isSelected: _selected.containsKey(c.id),
                      onToggle: (v) => setState(() {
                        if (v) {
                          _selected[c.id] = null;
                        } else {
                          _selected.remove(c.id);
                        }
                      }),
                      onAmountEdit: (a) => setState(() => _selected[c.id] = a),
                    ),
                  ),
                ],

                // Rebate credits section
                if (_rebates.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _SectionLabel(
                    icon: Icons.redeem_rounded,
                    label: 'credit_card.rebate_credits_title'.tr,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ..._rebates.map((r) => _RebateCreditTile(
                        charge: r,
                        isApplied: _appliedRebateIds.contains(r.id),
                        onToggle: (v) => setState(() {
                          if (v) {
                            _appliedRebateIds.add(r.id);
                          } else {
                            _appliedRebateIds.remove(r.id);
                          }
                        }),
                      )),
                ],

                // Total breakdown box
                if (_selected.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Charges row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'credit_card.payment_total'.tr,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _currFmt.format(_totalSelected),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                        // Credits row (if any applied)
                        if (_appliedCredits > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'credit_card.rebate_credits_applied'.tr,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.teal,
                                ),
                              ),
                              Text(
                                '- ${_currFmt.format(_appliedCredits)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Divider(height: AppSpacing.md, color: cs.outline.withValues(alpha: 0.3)),
                        ],
                        // Net row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'credit_card.payment_net'.tr,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _currFmt.format(_netPayable),
                              style: AppTextStyles.h3.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),

                // Source saving — only when net cash > 0 and non-reserved charges exist
                if (_needsSourceSaving) ...[
                  _SectionLabel(
                    icon: Icons.account_balance_outlined,
                    label: 'credit_card.payment_source'.tr,
                    color: cs.secondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FormField<FormAccountItem>(
                    validator: (_) =>
                        _needsSourceSaving && _sourceSaving == null
                        ? 'general.required'.tr
                        : null,
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormAccountSelector(
                          label: 'credit_card.payment_source'.tr,
                          selectedAccount: _sourceSaving,
                          accounts: _savings,
                          onAccountSelected: (a) =>
                              setState(() => _sourceSaving = a),
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
                  const SizedBox(height: AppSpacing.md),
                ],
              ],

              // Date & note
              _DatePickerTile(
                label: 'credit_card.payment_date_prefix'.tr,
                date: _paymentDate,
                onPicked: (d) => setState(() => _paymentDate = d),
              ),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit
              FormField<void>(
                validator: (_) {
                  if (_activeCharges.isNotEmpty && _selected.isEmpty) {
                    return 'credit_card.select_at_least_one'.tr;
                  }
                  return null;
                },
                builder: (field) => Column(
                  children: [
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(color: cs.error, fontSize: 13),
                        ),
                      ),
                    AppButton.primary(
                      label: 'credit_card.payment_btn'.tr,
                      onPressed: _activeCharges.isEmpty
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final cashAllocs = _buildCashAllocations();
                                final rebateAllocs = _buildRebateAllocations();

                                // Source saving: user-selected, or fall back to
                                // the first reserved saving among selected charges.
                                final fallback =
                                    _sourceSaving?.id ??
                                    _activeCharges
                                        .firstWhere(
                                          (c) =>
                                              c.reservedSavingId != null &&
                                              _selected.containsKey(c.id),
                                          orElse: () => _activeCharges.first,
                                        )
                                        .reservedSavingId ??
                                    '';

                                widget.onAdd(
                                  _netPayable,
                                  fallback,
                                  _paymentDate,
                                  _noteCtrl.text.trim().isEmpty
                                      ? null
                                      : _noteCtrl.text.trim(),
                                  cashAllocs.isNotEmpty ? cashAllocs : null,
                                  rebateAllocs.isNotEmpty ? rebateAllocs : null,
                                );
                                Navigator.pop(context);
                              }
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── charge select tile ─────────────────────────────────────────────────────────

class _ChargeSelectTile extends StatelessWidget {
  final CrdCardCharge charge;
  final double unpaidAmount;
  final double payAmount;
  final bool isSelected;
  final void Function(bool) onToggle;
  final void Function(double) onAmountEdit;

  const _ChargeSelectTile({
    required this.charge,
    required this.unpaidAmount,
    required this.payAmount,
    required this.isSelected,
    required this.onToggle,
    required this.onAmountEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isReserved = charge.reservedSavingId != null;
    final isPartial = payAmount < unpaidAmount;

    return GestureDetector(
      onTap: () => onToggle(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isReserved
                    ? cs.primaryContainer.withValues(alpha: 0.4)
                    : cs.secondaryContainer.withValues(alpha: 0.4))
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? (isReserved ? cs.primary : cs.secondary).withValues(
                    alpha: 0.5,
                  )
                : cs.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isReserved ? cs.primary : cs.secondary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? (isReserved ? cs.primary : cs.secondary)
                      : cs.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 14, color: cs.onPrimary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    charge.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _dateFmt.format(charge.chargeDate),
                        style: AppTextStyles.caption.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (isReserved) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.savings_outlined,
                                size: 9,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'credit_card.auto_deduct'.tr,
                                style: AppTextStyles.caption.copyWith(
                                  color: cs.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Show "RM X of RM Y unpaid" when partially paid
                  if (unpaidAmount < charge.amount)
                    Text(
                      'credit_card.remaining_of'.trWith({
                        'remaining': _currFmt.format(unpaidAmount),
                        'total': _currFmt.format(charge.amount),
                      }),
                      style: AppTextStyles.caption.copyWith(
                        color: cs.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // Tappable amount (edit when selected)
            GestureDetector(
              onTap: isSelected ? () => _showAmountOverride(context) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isReserved ? cs.primary : cs.secondary).withValues(
                          alpha: 0.15,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currFmt.format(payAmount),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? (isReserved ? cs.primary : cs.secondary)
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        if (isPartial)
                          Text(
                            'of ${_currFmt.format(unpaidAmount)}',
                            style: AppTextStyles.caption.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: isReserved ? cs.primary : cs.secondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAmountOverride(BuildContext context) {
    final ctrl = TextEditingController(text: payAmount.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('credit_card.override_amount'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              charge.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${'credit_card.unpaid_amount'.tr}: ${_currFmt.format(unpaidAmount)}',
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'credit_card.payment_amount'.tr,
                prefixText: 'RM ',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              onAmountEdit(unpaidAmount);
              Navigator.pop(ctx);
            },
            child: Text('credit_card.full_amount'.tr),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null && v > 0 && v <= unpaidAmount) {
                onAmountEdit(v);
              }
              Navigator.pop(ctx);
            },
            child: Text('general.apply'.tr),
          ),
        ],
      ),
    );
  }
}

// ── rebate credit tile ─────────────────────────────────────────────────────────

class _RebateCreditTile extends StatelessWidget {
  final CrdCardCharge charge;
  final bool isApplied;
  final ValueChanged<bool> onToggle;

  const _RebateCreditTile({
    required this.charge,
    required this.isApplied,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isApplied
            ? Colors.teal.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isApplied
              ? Colors.teal.withValues(alpha: 0.4)
              : cs.outline.withValues(alpha: 0.2),
        ),
      ),
      child: CheckboxListTile(
        dense: true,
        value: isApplied,
        onChanged: (v) => onToggle(v ?? false),
        activeColor: Colors.teal,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          charge.description,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: charge.note != null && charge.note!.isNotEmpty
            ? Text(
                charge.note!,
                style: AppTextStyles.caption.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            : null,
        secondary: Text(
          '+ ${_currFmt.format(charge.amount.abs())}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.teal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── date picker tile ───────────────────────────────────────────────────────────

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final void Function(DateTime) onPicked;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: cs.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$label: ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              _dateFmt.format(date),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _PeriodSelector widget ─────────────────────────────────────────────────
class _PeriodSelector extends StatelessWidget {
  final ChargePeriod current;
  final void Function(ChargePeriod) onChanged;

  const _PeriodSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: ChargePeriod.values.map((p) {
          final selected = p == current;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: selected ? cs.primary : cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: selected ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Text(
                  p.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
