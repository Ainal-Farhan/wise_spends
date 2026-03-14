// transaction_account_selector.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'transaction_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Single account selector
// ─────────────────────────────────────────────────────────────────────────────

class TransactionAccountDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final String? selectedId;
  final List<ListSavingVO> savingsList;
  final String? excludeId;
  final ValueChanged<String?> onChanged;

  const TransactionAccountDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.selectedId,
    required this.savingsList,
    this.excludeId,
    required this.onChanged,
  });

  @override
  State<TransactionAccountDropdown> createState() =>
      _TransactionAccountDropdownState();
}

class _TransactionAccountDropdownState
    extends State<TransactionAccountDropdown> {
  late final TextEditingController _controller;

  List<ListSavingVO> get _available =>
      widget.savingsList.where((s) => s.saving.id != widget.excludeId).toList();

  ListSavingVO? get _selected => _available.cast<ListSavingVO?>().firstWhere(
    (s) => s?.saving.id == widget.selectedId,
    orElse: () => null,
  );

  String _displayText(ListSavingVO? s) => s == null
      ? ''
      : '${s.saving.name ?? 'transaction.account.unnamed'.tr}  ·  RM ${s.saving.currentAmount.toStringAsFixed(2)}';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayText(_selected));
  }

  @override
  void didUpdateWidget(TransactionAccountDropdown old) {
    super.didUpdateWidget(old);
    // Update text whenever selection or list changes
    if (old.selectedId != widget.selectedId ||
        old.savingsList != widget.savingsList) {
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

    if (available.isEmpty) return const _NoAccountsHint();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: widget.label),
        const SizedBox(height: 8),
        AppTextField(
          hint: widget.hint,
          readOnly: true,
          prefixWidget: _selected != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _SavingTypeIcon(type: _selected!.saving.type),
                )
              : null,
          prefixIcon: _selected == null ? Icons.account_balance_rounded : null,
          suffixIcon: Icons.keyboard_arrow_down_rounded,
          controller: _controller,
          onTap: () => _showPicker(context, available),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context, List<ListSavingVO> available) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountPickerSheet(
        accounts: available,
        selectedId: widget.selectedId,
        onSelected: (id) {
          widget.onChanged(id);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transfer selector (two dropdowns with arrow)
// ─────────────────────────────────────────────────────────────────────────────

class TransferAccountSelector extends StatelessWidget {
  final String? sourceAccountId;
  final String? destinationAccountId;
  final List<ListSavingVO> savingsList;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<String?> onDestinationChanged;

  const TransferAccountSelector({
    super.key,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.savingsList,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: 'transaction.transfer.between_accounts'.tr),
        const SizedBox(height: 12),
        TransactionAccountDropdown(
          label: 'transaction.transfer.from'.tr,
          hint: 'transaction.transfer.from_hint'.tr,
          selectedId: sourceAccountId,
          savingsList: savingsList,
          excludeId: destinationAccountId,
          onChanged: onSourceChanged,
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TransactionAccountDropdown(
          label: 'transaction.transfer.to'.tr,
          hint: 'transaction.transfer.to_hint'.tr,
          selectedId: destinationAccountId,
          savingsList: savingsList,
          excludeId: sourceAccountId,
          onChanged: onDestinationChanged,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AccountChip (locked fields)
// ─────────────────────────────────────────────────────────────────────────────

class AccountChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const AccountChip({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet picker
// ─────────────────────────────────────────────────────────────────────────────

class _AccountPickerSheet extends StatelessWidget {
  final List<ListSavingVO> accounts;
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
        color: AppColors.background,
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
              color: AppColors.divider,
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
                final isSelected = account.saving.id == selectedId;
                return _AccountTile(
                  account: account,
                  isSelected: isSelected,
                  onTap: () => onSelected(account.saving.id),
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
  final ListSavingVO account;
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
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _SavingTypeIcon(type: account.saving.type),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                account.saving.name ?? 'transaction.account.unnamed'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'RM ${account.saving.currentAmount.toStringAsFixed(2)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 18,
                      key: ValueKey('check'),
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      color: AppColors.divider,
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
// Shared private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SavingTypeIcon extends StatelessWidget {
  final String type;

  const _SavingTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type.toLowerCase()) {
      'cash' => (Icons.payments_rounded, AppColors.success),
      'bank' ||
      'bank_account' => (Icons.account_balance_rounded, AppColors.primary),
      'credit' ||
      'credit_card' => (Icons.credit_card_rounded, AppColors.secondary),
      'ewallet' ||
      'e_wallet' => (Icons.phone_android_rounded, AppColors.tertiary),
      'savings' => (Icons.savings_rounded, AppColors.income),
      _ => (Icons.account_balance_wallet_rounded, AppColors.textSecondary),
    };
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _NoAccountsHint extends StatelessWidget {
  const _NoAccountsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'transaction.account.no_accounts'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
