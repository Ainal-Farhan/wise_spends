// form_locked_fields.dart
// Locked/display-only field variants for edit mode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'form_account_selector.dart';
import 'form_category_picker.dart';
import 'form_payee_picker.dart';
import 'form_type_toggle.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Edit mode banner
// ─────────────────────────────────────────────────────────────────────────────

class EditModeBanner extends StatelessWidget {
  const EditModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'transaction.edit_mode.title'.tr,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'transaction.edit_mode.subtitle'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 11,
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

// ─────────────────────────────────────────────────────────────────────────────
// Locked amount display
// ─────────────────────────────────────────────────────────────────────────────

class LockedAmountDisplay extends StatelessWidget {
  final String amount;
  final FormTransactionType transactionType;
  final String? label;
  final String currencySymbol;

  const LockedAmountDisplay({
    super.key,
    required this.amount,
    required this.transactionType,
    this.label,
    this.currencySymbol = 'RM',
  });

  @override
  Widget build(BuildContext context) {
    final color = transactionType.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) _SectionLabel(text: label!),
        if (label != null) const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$currencySymbol $amount',
                  style: AppTextStyles.amountXLarge.copyWith(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locked category display
// ─────────────────────────────────────────────────────────────────────────────

class LockedCategoryDisplay extends StatelessWidget {
  final FormCategoryItem? category;
  final String? label;

  const LockedCategoryDisplay({super.key, this.category, this.label});

  @override
  Widget build(BuildContext context) {
    return LockedField(
      label: label ?? 'transaction.add.category'.tr,
      child: Row(
        children: [
          if (category != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(category!.icon, size: 14, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              category?.name ?? 'transaction.not_set'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locked payee display
// ─────────────────────────────────────────────────────────────────────────────

class LockedPayeeDisplay extends StatelessWidget {
  final FormPayeeItem? payee;
  final String? label;

  const LockedPayeeDisplay({super.key, this.payee, this.label});

  @override
  Widget build(BuildContext context) {
    return LockedField(
      label: label ?? 'transaction.add.payee'.tr,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payee?.displayName ?? 'transaction.not_set'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (payee?.subtitle != null)
                  Text(
                    payee!.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

// ─────────────────────────────────────────────────────────────────────────────
// Locked account display
// ─────────────────────────────────────────────────────────────────────────────

class LockedAccountDisplay extends StatelessWidget {
  final FormAccountItem? account;
  final String? label;

  const LockedAccountDisplay({super.key, this.account, this.label});

  @override
  Widget build(BuildContext context) {
    return LockedField(
      label: label ?? 'transaction.add.account'.tr,
      child: Row(
        children: [
          if (account != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: account!.typeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                account!.typeIcon,
                size: 14,
                color: account!.typeColor,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account?.name ?? 'transaction.not_set'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (account != null)
                  Text(
                    account!.displayBalance,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

// ─────────────────────────────────────────────────────────────────────────────
// Locked date/time display
// ─────────────────────────────────────────────────────────────────────────────

class LockedDateTimeDisplay extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final String? label;

  const LockedDateTimeDisplay({
    super.key,
    required this.selectedDate,
    this.selectedTime,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return LockedField(
      label: label ?? 'transaction.add.date_time'.tr,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(selectedDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedTime != null)
                  Text(
                    selectedTime!.format(context),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'transaction.history.today'.tr;
    if (d == yesterday) return 'general.yesterday'.tr;
    if (date.year == now.year) return DateFormat('EEE, d MMM').format(date);
    return DateFormat('d MMM y').format(date);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locked type display
// ─────────────────────────────────────────────────────────────────────────────

class LockedTypeDisplay extends StatelessWidget {
  final FormTransactionType transactionType;
  final String? label;

  const LockedTypeDisplay({
    super.key,
    required this.transactionType,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = transactionType.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) _SectionLabel(text: label!),
        if (label != null) const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(transactionType.icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  transactionType.translatedLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic locked field wrapper
// ─────────────────────────────────────────────────────────────────────────────

class LockedField extends StatelessWidget {
  final String label;
  final Widget child;

  const LockedField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: label),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: child),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.divider.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account chip (for transfer display)
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
