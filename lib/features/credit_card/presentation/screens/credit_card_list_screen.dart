import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_list_bloc.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_list_event.dart';
import 'package:wise_spends/features/credit_card/presentation/bloc/credit_card_list_state.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'widgets/credit_card_form_widgets.dart';

final _currFmt = NumberFormat.currency(symbol: 'RM ');

class CreditCardListScreen extends StatelessWidget {
  const CreditCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getCreditCardRepository();
    return BlocProvider(
      create: (_) => CreditCardListBloc(repo)..add(LoadCreditCardsEvent()),
      child: const _CreditCardListContent(),
    );
  }
}

enum _CardFilterTab { all, creditCard, payLater }

class _CreditCardListContent extends StatefulWidget {
  const _CreditCardListContent();

  @override
  State<_CreditCardListContent> createState() => _CreditCardListContentState();
}

class _CreditCardListContentState extends State<_CreditCardListContent> {
  _CardFilterTab _tab = _CardFilterTab.all;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('credit_card.title'.tr),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const NavigationSidebar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCardSheet(context),
        icon: const Icon(Icons.add_card_rounded),
        label: Text('credit_card.add'.tr),
      ),
      body: BlocBuilder<CreditCardListBloc, CreditCardListState>(
        builder: (context, state) {
          if (state is CreditCardListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CreditCardError) {
            return Center(child: Text(state.message));
          }
          if (state is CreditCardListLoaded) {
            if (state.summaries.isEmpty) {
              return _EmptyState();
            }

            final filtered = state.summaries.where((s) {
              return switch (_tab) {
                _CardFilterTab.all => true,
                _CardFilterTab.creditCard =>
                  s.card.cardType == 'credit_card',
                _CardFilterTab.payLater => s.card.cardType == 'pay_later',
              };
            }).toList();

            final totalDebt =
                filtered.fold<double>(0, (s, c) => s + c.totalDebt);
            final totalLimit =
                filtered.fold<double>(0, (s, c) => s + c.card.creditLimit);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SummaryHeader(
                    cardCount: filtered.length,
                    totalDebt: totalDebt,
                    totalLimit: totalLimit,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Row(
                      children: _CardFilterTab.values.map((tab) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: FilterChip(
                            label: Text(_tabLabel(tab)),
                            selected: _tab == tab,
                            onSelected: (_) => setState(() => _tab = tab),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxxl + 72,
                  ),
                  sliver: SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final summary = filtered[index];
                      return _CreditCardTile(
                        summary: summary,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.creditCardDetail,
                          arguments: summary.card.id,
                        ).then(
                          (_) => context
                              .read<CreditCardListBloc>()
                              .add(LoadCreditCardsEvent()),
                        ),
                        onDelete: () => _confirmDelete(
                          context,
                          summary.card.id,
                          summary.card.name,
                        ),
                      );
                    },
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

  String _tabLabel(_CardFilterTab tab) => switch (tab) {
    _CardFilterTab.all => 'All',
    _CardFilterTab.creditCard => 'Credit Card',
    _CardFilterTab.payLater => 'Pay Later',
  };


  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('credit_card.delete_title'.tr),
        content: Text(
            'credit_card.delete_confirm'.trWith({'name': name})),
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
              context
                  .read<CreditCardListBloc>()
                  .add(DeleteCreditCardEvent(id));
            },
            child: Text('general.delete'.tr),
          ),
        ],
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddCardSheetProxy(
        onAdd: (name, last4, limit, stmtDay, dueDay, note, cardType, providerName) {
          context.read<CreditCardListBloc>().add(
            AddCreditCardEvent(
              name: name,
              lastFourDigits: last4,
              creditLimit: limit,
              statementDay: stmtDay,
              dueDay: dueDay,
              note: note,
              cardType: cardType,
              providerName: providerName,
            ),
          );
        },
      ),
    );
  }
}

/// Thin proxy so the list screen can open the shared _CardFormSheet without
/// importing the detail screen internals.  We duplicate the minimal form here
/// since _CardFormSheet lives in credit_card_detail_screen.dart.
class _AddCardSheetProxy extends StatefulWidget {
  final void Function(String, String?, double, int, int, String?, String, String?) onAdd;
  const _AddCardSheetProxy({required this.onAdd});

  @override
  State<_AddCardSheetProxy> createState() => _AddCardSheetProxyState();
}

class _AddCardSheetProxyState extends State<_AddCardSheetProxy> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _last4Ctrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  int _statementDay = 1;
  int _dueDay = 1;
  String _cardType = 'credit_card';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _last4Ctrl.dispose();
    _limitCtrl.dispose();
    _noteCtrl.dispose();
    _providerCtrl.dispose();
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
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.add_card_rounded,
                        color: cs.onSecondaryContainer),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('credit_card.add'.tr, style: AppTextStyles.h3),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Card type selector
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Credit Card',
                      icon: Icons.credit_card_rounded,
                      selected: _cardType == 'credit_card',
                      onTap: () => setState(() => _cardType = 'credit_card'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TypeButton(
                      label: 'Pay Later',
                      icon: Icons.schedule_send_rounded,
                      selected: _cardType == 'pay_later',
                      onTap: () => setState(() => _cardType = 'pay_later'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _nameCtrl,
                label: 'credit_card.field_name'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
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
              AppTextField(
                controller: _limitCtrl,
                label: _cardType == 'pay_later'
                    ? 'Spending Limit'
                    : 'credit_card.field_limit'.tr,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'general.required'.tr;
                  if (double.tryParse(v) == null) {
                    return 'general.invalid_number'.tr;
                  }
                  return null;
                },
              ),
              if (_cardType == 'pay_later') ...[
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _providerCtrl,
                  label: 'Provider (e.g. Atome, GrabPay Later)',
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              CcDayPickerField(
                label: 'credit_card.field_statement_day'.tr,
                hint: 'credit_card.statement_day_hint'.tr,
                value: _statementDay,
                onChanged: (d) => setState(() => _statementDay = d),
              ),
              const SizedBox(height: AppSpacing.sm),
              CcDayPickerField(
                label: 'credit_card.field_due_day'.tr,
                hint: 'credit_card.due_day_hint'.tr,
                value: _dueDay,
                onChanged: (d) => setState(() => _dueDay = d),
              ),
              CcBillingCyclePreview(
                  statementDay: _statementDay, dueDay: _dueDay),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'credit_card.btn_add'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
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
                      _cardType,
                      _providerCtrl.text.trim().isEmpty
                          ? null
                          : _providerCtrl.text.trim(),
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

// ── type button ───────────────────────────────────────────────────────────────

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── summary header ─────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final int cardCount;
  final double totalDebt;
  final double totalLimit;

  const _SummaryHeader({
    required this.cardCount,
    required this.totalDebt,
    required this.totalLimit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final usedPct =
        totalLimit > 0 ? (totalDebt / totalLimit).clamp(0.0, 1.0) : 0.0;
    final barColor = usedPct > 0.8
        ? cs.error
        : usedPct > 0.5
            ? cs.tertiary
            : cs.primary;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.secondaryContainer, cs.secondaryContainer.withValues(alpha: 0.5)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: cs.onSecondaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.credit_card_rounded,
                    size: 16, color: cs.onSecondaryContainer),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$cardCount ${'credit_card.title'.tr}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSecondaryContainer.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _currFmt.format(totalDebt),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cs.onSecondaryContainer,
            ),
          ),
          Text(
            'credit_card.label_debt'.tr,
            style: AppTextStyles.caption.copyWith(
              color: cs.onSecondaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
            '${(usedPct * 100).toStringAsFixed(0)}% of ${_currFmt.format(totalLimit)} used',
            style: AppTextStyles.caption.copyWith(
              color: cs.onSecondaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── card tile ──────────────────────────────────────────────────────────────────

class _CreditCardTile extends StatelessWidget {
  final dynamic summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CreditCardTile({
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final card = summary.card;
    final usedPct = card.creditLimit > 0
        ? (summary.totalDebt / card.creditLimit).clamp(0.0, 1.0)
        : 0.0;
    final barColor = usedPct > 0.8
        ? cs.error
        : usedPct > 0.5
            ? cs.tertiary
            : cs.primary;
    final available = (card.creditLimit - summary.totalDebt)
        .clamp(0.0, double.infinity);

    return GestureDetector(
      onLongPress: onDelete,
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card name + last4
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        card.cardType == 'pay_later'
                            ? Icons.schedule_send_rounded
                            : Icons.credit_card_rounded,
                        size: 20,
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (card.cardType == 'pay_later')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.tertiaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                              child: Text(
                                card.providerName ?? 'Pay Later',
                                style: AppTextStyles.caption.copyWith(
                                  color: cs.onTertiaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          else if (card.lastFourDigits != null)
                            Text(
                              '•••• ${card.lastFourDigits}',
                              style: AppTextStyles.caption.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCell(
                        label: 'credit_card.label_debt'.tr,
                        value: _currFmt.format(summary.totalDebt),
                        valueColor:
                            summary.totalDebt > 0 ? cs.error : cs.primary,
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        label: 'credit_card.label_available'.tr,
                        value: _currFmt.format(available),
                        valueColor: cs.primary,
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        label: 'credit_card.label_limit'.tr,
                        value: _currFmt.format(card.creditLimit),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Utilisation bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: usedPct,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(barColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(usedPct * 100).toStringAsFixed(0)}% used',
                      style: AppTextStyles.caption.copyWith(
                        color: barColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'credit_card.statement_due'.trWith({
                        'stmt': card.statementDay.toString(),
                        'due': card.dueDay.toString(),
                      }),
                      style: AppTextStyles.caption.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
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

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCell({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.credit_card_off_rounded,
                size: 48, color: cs.secondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('credit_card.empty'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── add card sheet ─────────────────────────────────────────────────────────────

class _AddCardSheet extends StatefulWidget {
  final void Function(
    String name,
    String? lastFourDigits,
    double creditLimit,
    int statementDay,
    int dueDay,
    String? note,
  ) onAdd;

  const _AddCardSheet({required this.onAdd});

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _last4Ctrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _stmtDayCtrl = TextEditingController();
  final _dueDayCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _last4Ctrl.dispose();
    _limitCtrl.dispose();
    _stmtDayCtrl.dispose();
    _dueDayCtrl.dispose();
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
              // Drag handle
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

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(Icons.add_card_rounded,
                        color: cs.onSecondaryContainer),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('credit_card.add'.tr, style: AppTextStyles.h3),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Card name + last4 in a row
              AppTextField(
                controller: _nameCtrl,
                label: 'credit_card.field_name'.tr,
                validator: (v) =>
                    v == null || v.isEmpty ? 'general.required'.tr : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _last4Ctrl,
                label: 'credit_card.field_last4'.tr,
                keyboardType: AppTextFieldKeyboardType.number,
              ),
              const SizedBox(height: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.sm),

              // Statement + Due days in a row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _stmtDayCtrl,
                      label: 'credit_card.field_statement_day'.tr,
                      keyboardType: AppTextFieldKeyboardType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 31) return '1-31';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _dueDayCtrl,
                      label: 'credit_card.field_due_day'.tr,
                      keyboardType: AppTextFieldKeyboardType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1 || n > 31) return '1-31';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _noteCtrl,
                label: 'general.note_optional'.tr,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: 'credit_card.btn_add'.tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      _nameCtrl.text.trim(),
                      _last4Ctrl.text.trim().isEmpty
                          ? null
                          : _last4Ctrl.text.trim(),
                      double.parse(_limitCtrl.text),
                      int.parse(_stmtDayCtrl.text),
                      int.parse(_dueDayCtrl.text),
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
