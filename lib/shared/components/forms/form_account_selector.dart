// form_account_selector.dart
// Reusable account/savings selector for forms
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/saving/domain/entities/reserve_vo.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/components/reservation_info_widget.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _logger = WiseLogger();

/// Account item for the selector
class FormAccountItem {
  final String id;
  final String name;
  final String type; // cash, bank, credit_card, ewallet, savings
  final double balance;
  final String? currencySymbol;
  final CategoryEntity? category;

  /// Optional reservation summary for savings accounts
  final SavingsReserveSummary? reserveSummary;

  const FormAccountItem({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currencySymbol = 'RM',
    this.category,
    this.reserveSummary,
  });

  String get displayBalance => '$currencySymbol ${balance.toStringAsFixed(2)}';

  /// Transferable amount (balance minus reserved)
  double get transferableAmount {
    if (reserveSummary == null) return balance;
    return reserveSummary!.transferableAmount;
  }

  /// Whether this account has reservations
  bool get hasReservations => reserveSummary?.hasReservations ?? false;

  /// Display balance - shows transferable amount if there are reservations
  String get displayTransferableAmount {
    if (!hasReservations) return displayBalance;
    return '$currencySymbol ${transferableAmount.toStringAsFixed(2)}';
  }

  IconData get typeIcon {
    return switch (type.toLowerCase()) {
      'cash' => Icons.payments_rounded,
      'bank' || 'bank_account' => Icons.account_balance_rounded,
      'credit' || 'credit_card' => Icons.credit_card_rounded,
      'ewallet' || 'e_wallet' => Icons.phone_android_rounded,
      'savings' => Icons.savings_rounded,
      _ => Icons.account_balance_wallet_rounded,
    };
  }

  Color getTypeColor(BuildContext context) {
    return switch (type.toLowerCase()) {
      'cash' => Theme.of(context).colorScheme.primary,
      'bank' || 'bank_account' => Theme.of(context).colorScheme.primary,
      'credit' || 'credit_card' => Theme.of(context).colorScheme.secondary,
      'ewallet' || 'e_wallet' => Theme.of(context).colorScheme.tertiary,
      'savings' => Theme.of(context).colorScheme.primary,
      _ => Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }
}

class FormAccountSelector extends StatefulWidget {
  final FormAccountItem? selectedAccount;
  final List<FormAccountItem> accounts;
  final String? excludeId;
  final String? label;
  final String? hint;
  final bool enabled;
  final ValueChanged<FormAccountItem?> onAccountSelected;

  const FormAccountSelector({
    super.key,
    this.selectedAccount,
    required this.accounts,
    this.excludeId,
    this.label,
    this.hint,
    this.enabled = true,
    required this.onAccountSelected,
  });

  @override
  State<FormAccountSelector> createState() => _FormAccountSelectorState();
}

class _FormAccountSelectorState extends State<FormAccountSelector> {
  late final TextEditingController _controller;

  List<FormAccountItem> get _available =>
      widget.accounts.where((a) => a.id != widget.excludeId).toList();

  FormAccountItem? get _selected =>
      _available.cast<FormAccountItem?>().firstWhere(
        (a) => a?.id == widget.selectedAccount?.id,
        orElse: () => null,
      );

  String _displayText(FormAccountItem? a) => a == null
      ? ''
      : '${a.name}  ·  ${a.transferableAmount.toStringAsFixed(2)}';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayText(_selected));
  }

  @override
  void didUpdateWidget(FormAccountSelector old) {
    super.didUpdateWidget(old);
    if (old.selectedAccount?.id != widget.selectedAccount?.id ||
        old.accounts != widget.accounts) {
      _controller.text = _displayText(_selected);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = _available;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) _SectionLabel(text: widget.label!),
        if (widget.label != null) const SizedBox(height: 8),
        if (available.isEmpty)
          _NoAccountsHint()
        else
          AppTextField(
            hint: widget.hint ?? 'transaction.account.select'.tr,
            readOnly: true,
            enabled: widget.enabled,
            prefixWidget: _selected != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _AccountTypeIcon(account: _selected!),
                  )
                : null,
            prefixIcon: _selected == null
                ? Icons.account_balance_rounded
                : null,
            suffixIcon: Icons.keyboard_arrow_down_rounded,
            controller: _controller,
            onTap: widget.enabled
                ? () => _showPicker(context, available)
                : null,
          ),
      ],
    );
  }

  void _showPicker(BuildContext context, List<FormAccountItem> available) {
    _logger.debug(
      'Opening account picker, ${available.length} accounts available',
      tag: 'FormAccountSelector',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountPickerSheet(
        accounts: available,
        selectedId: widget.selectedAccount?.id,
        onSelected: (id) {
          final account = available.firstWhere((a) => a.id == id);
          _logger.debug(
            'Account selected: ${account.name} (${account.id})',
            tag: 'FormAccountSelector',
          );
          widget.onAccountSelected(account);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transfer account selector (source and destination)
// ─────────────────────────────────────────────────────────────────────────────

class FormTransferAccountSelector extends StatelessWidget {
  final FormAccountItem? sourceAccount;
  final FormAccountItem? destinationAccount;
  final List<FormAccountItem> accounts;
  final String? label;
  final bool enabled;
  final ValueChanged<FormAccountItem?> onSourceChanged;
  final ValueChanged<FormAccountItem?> onDestinationChanged;

  const FormTransferAccountSelector({
    super.key,
    this.sourceAccount,
    this.destinationAccount,
    required this.accounts,
    this.label,
    this.enabled = true,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) _SectionLabel(text: label!),
        if (label != null) const SizedBox(height: 12),
        FormAccountSelector(
          selectedAccount: sourceAccount,
          accounts: accounts,
          excludeId: destinationAccount?.id,
          label: 'transaction.transfer.from'.tr,
          hint: 'transaction.transfer.from_hint'.tr,
          enabled: enabled,
          onAccountSelected: onSourceChanged,
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: Theme.of(context).canvasColor,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        FormAccountSelector(
          selectedAccount: destinationAccount,
          accounts: accounts,
          excludeId: sourceAccount?.id,
          label: 'transaction.transfer.to'.tr,
          hint: 'transaction.transfer.to_hint'.tr,
          enabled: enabled,
          onAccountSelected: onDestinationChanged,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet picker
// ─────────────────────────────────────────────────────────────────────────────

class _AccountPickerSheet extends StatelessWidget {
  final List<FormAccountItem> accounts;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _AccountPickerSheet({
    required this.accounts,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'transaction.account.select'.tr,
              style: AppTextStyles.h3,
            ),
          ),
          const SizedBox(height: 16),

          // Account tiles
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = accounts[index];
                final isSelected = account.id == selectedId;
                return _AccountTile(
                  account: account,
                  isSelected: isSelected,
                  onTap: () => onSelected(account.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final FormAccountItem account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? account.getTypeColor(context).withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? account.getTypeColor(context).withValues(alpha: 0.4)
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _AccountTypeIcon(account: account),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          account.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? account.getTypeColor(context)
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Show reservation info icon for savings with reservations
                      if (account.hasReservations) ...[
                        const SizedBox(width: 8),
                        ReservationInfoIcon(
                          reserveSummary: account.reserveSummary!,
                          iconSize: 14,
                          savingName: account.name,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              account.displayTransferableAmount,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? account.getTypeColor(context).withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                      key: ValueKey('check'),
                    )
                  : Icon(
                      Icons.circle_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 18,
                      key: ValueKey('empty'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account type icon
// ─────────────────────────────────────────────────────────────────────────────

class _AccountTypeIcon extends StatelessWidget {
  final FormAccountItem account;

  const _AccountTypeIcon({required this.account});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: account.getTypeColor(context).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: account.hasReservations
              ? ReservationInfoIcon(
                  iconData: account.typeIcon,
                  reserveSummary: account.reserveSummary!,
                  iconSize: 14,
                  savingName: account.name,
                )
              : Icon(
                  account.typeIcon,
                  color: account.getTypeColor(context),
                  size: 16,
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No accounts hint
// ─────────────────────────────────────────────────────────────────────────────

class _NoAccountsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'transaction.account.no_accounts'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.bodySemiBold);
  }
}
