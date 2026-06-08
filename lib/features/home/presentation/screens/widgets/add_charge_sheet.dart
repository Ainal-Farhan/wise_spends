import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/transaction/presentation/adapters/transaction_form_adapters.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

/// Shows the Add Charge bottom sheet and returns after saving.
Future<void> showAddChargeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddChargeSheet(),
  );
}

class _AddChargeSheet extends StatefulWidget {
  const _AddChargeSheet();

  @override
  State<_AddChargeSheet> createState() => _AddChargeSheetState();
}

class _AddChargeSheetState extends State<_AddChargeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<CrdCardCreditCard> _cards = [];
  List<FormAccountItem> _savings = [];
  CrdCardCreditCard? _selectedCard;
  FormAccountItem? _reservedSaving;
  DateTime _chargeDate = DateTime.now();
  bool _reserveEnabled = false;
  bool _isRebate = false;
  bool _isPending = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final locator = SingletonUtil.getSingleton<IRepositoryLocator>()!;
      final cards = await locator.getCreditCardRepository().getAllCards();
      final savings = await locator.getSavingRepository().getAllSavings();
      if (mounted) {
        setState(() {
          _cards = cards;
          _savings = savings.map((s) => s.toFormAccountItem()).toList();
          _selectedCard = cards.isNotEmpty ? cards.first : null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: _loading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : _cards.isEmpty
          ? _NoCardsState(cs: cs)
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Header row
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
                                : Icons.credit_card_rounded,
                            color: _isRebate
                                ? Colors.green.shade700
                                : cs.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          _isRebate
                              ? 'credit_card.add_rebate'.tr
                              : 'Add Charge',
                          style: AppTextStyles.h3,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Charge / Rebate toggle
                    Row(
                      children: [
                        Expanded(
                          child: _TypeBtn(
                            label: 'Charge',
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
                          child: _TypeBtn(
                            label: 'Rebate / Cashback',
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
                    // Card selector
                    _CardSelector(
                      cards: _cards,
                      selected: _selectedCard,
                      onSelected: (c) => setState(() => _selectedCard = c),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _descCtrl,
                      label: _isRebate
                          ? 'Rebate Description'
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
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _chargeDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _chargeDate = picked);
                        }
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
                              _dateFmt.format(_chargeDate),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppTextField(
                      controller: _noteCtrl,
                      label: 'general.note_optional'.tr,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Pending toggle
                    if (!_isRebate)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _isPending
                              ? Colors.amber.shade50
                              : cs.surfaceContainerHighest.withValues(
                                  alpha: 0.4,
                                ),
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
                            style: AppTextStyles.caption.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          value: _isPending,
                          onChanged: (v) => setState(() => _isPending = v),
                        ),
                      ),
                    // Reserve toggle
                    if (!_isRebate)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _reserveEnabled
                              ? cs.primaryContainer.withValues(alpha: 0.3)
                              : cs.surfaceContainerHighest.withValues(
                                  alpha: 0.4,
                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                    AppButton.primary(
                      label: _isRebate
                          ? 'credit_card.rebate_btn'.tr
                          : 'credit_card.charge_btn'.tr,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCard == null) return;

    try {
      final repo = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getCreditCardChargeRepository();
      await repo.addCharge(
        creditCardId: _selectedCard!.id,
        description: _descCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text),
        chargeDate: _chargeDate,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        reservedSavingId: (!_isRebate && _reserveEnabled)
            ? _reservedSaving?.id
            : null,
        status: _isPending ? 'pending' : 'posted',
        isRebate: _isRebate,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

// ── Card selector ──────────────────────────────────────────────────────────────

class _CardSelector extends StatelessWidget {
  final List<CrdCardCreditCard> cards;
  final CrdCardCreditCard? selected;
  final ValueChanged<CrdCardCreditCard> onSelected;

  const _CardSelector({
    required this.cards,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonFormField<CrdCardCreditCard>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: 'Card / Pay Later Account',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          selected?.cardType == 'pay_later'
              ? Icons.schedule_send_rounded
              : Icons.credit_card_rounded,
          color: cs.primary,
        ),
      ),
      items: cards.map((card) {
        final isPayLater = card.cardType == 'pay_later';
        return DropdownMenuItem(
          value: card,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPayLater
                    ? Icons.schedule_send_rounded
                    : Icons.credit_card_rounded,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(card.name, overflow: TextOverflow.ellipsis)),
              if (isPayLater && card.providerName != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    card.providerName!,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (c) {
        if (c != null) onSelected(c);
      },
      validator: (_) => selected == null ? 'general.required'.tr : null,
    );
  }
}

// ── Type toggle button ─────────────────────────────────────────────────────────

class _TypeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
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
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? color : cs.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? color : cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? color : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No cards empty state ───────────────────────────────────────────────────────

class _NoCardsState extends StatelessWidget {
  final ColorScheme cs;

  const _NoCardsState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card_off_rounded,
              size: 48,
              color: cs.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No cards or pay later accounts yet.\nAdd one from Cards & Pay Later.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
