// transaction_locked_displays.dart
// Locked (read-only) field displays for edit mode
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_bloc.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_state.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_form_state.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';
import 'transaction_form_widgets.dart';
import 'transaction_account_selector.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EDIT MODE BANNER
// ─────────────────────────────────────────────────────────────────────────────

class EditModeBanner extends StatelessWidget {
  const EditModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'transaction.edit.locked_fields_info'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCKED TYPE DISPLAY
// ─────────────────────────────────────────────────────────────────────────────

class LockedTypeDisplay extends StatelessWidget {
  final TransactionFormReady formState;

  const LockedTypeDisplay({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    final type = formState.transactionType;
    final color = type.color;

    return LockedField(
      label: 'transaction.field.type'.tr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, color: color, size: 15),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: AppTextStyles.bodySemiBold.copyWith(
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCKED AMOUNT DISPLAY
// ─────────────────────────────────────────────────────────────────────────────

class LockedAmountDisplay extends StatelessWidget {
  final TransactionFormReady formState;

  const LockedAmountDisplay({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    final color = formState.transactionType.color;
    return LockedField(
      label: 'transaction.field.amount'.tr,
      child: Text(
        'RM ${formState.amount ?? '0.00'}',
        style: AppTextStyles.amountXLarge.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCKED ACCOUNT DISPLAY
// ─────────────────────────────────────────────────────────────────────────────

class LockedAccountDisplay extends StatelessWidget {
  final TransactionFormReady formState;

  const LockedAccountDisplay({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        final list = state is SavingsListLoaded
            ? state.savingsList
            : <ListSavingVO>[];

        String nameFor(String? id) =>
            list
                .cast<ListSavingVO?>()
                .firstWhere((s) => s?.saving.id == id, orElse: () => null)
                ?.saving
                .name ??
            id ??
            'transaction.account.unknown'.tr;

        final isTransfer =
            formState.transactionType == TransactionType.transfer ||
            (formState.transactionType == TransactionType.commitment &&
                formState.selectedDestinationAccount != null);

        if (isTransfer) {
          return LockedField(
            label: 'transaction.field.transfer_accounts'.tr,
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AccountChip(
                  name: nameFor(formState.selectedSourceAccount),
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                AccountChip(
                  name: nameFor(formState.selectedDestinationAccount),
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.income,
                ),
              ],
            ),
          );
        }

        final isIncome = formState.transactionType == TransactionType.income;
        return LockedField(
          label: isIncome
              ? 'transaction.field.received_into'.tr
              : 'transaction.field.paid_from'.tr,
          child: AccountChip(
            name: nameFor(formState.selectedSourceAccount),
            icon: Icons.account_balance_rounded,
            color: AppColors.primary,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCKED CATEGORY DISPLAY
// ─────────────────────────────────────────────────────────────────────────────

class LockedCategoryDisplay extends StatelessWidget {
  final TransactionFormReady formState;

  const LockedCategoryDisplay({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    final category = formState.selectedCategory;
    final typeColor = formState.transactionType.color;

    if (category == null) {
      return LockedField(
        label: 'transaction.field.category'.tr,
        child: Text(
          'transaction.category.uncategorized'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return LockedField(
      label: 'transaction.field.category'.tr,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CategoryIconMapper.getIconForCategory(category.iconCodePoint),
              color: typeColor,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            category.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: typeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCKED PAYEE DISPLAY
// ─────────────────────────────────────────────────────────────────────────────

class LockedPayeeDisplay extends StatelessWidget {
  final TransactionFormReady formState;

  const LockedPayeeDisplay({super.key, required this.formState});

  @override
  Widget build(BuildContext context) {
    final payee = formState.selectedPayee;

    if (payee == null) {
      return LockedField(
        label: 'transaction.field.payee'.tr,
        child: Text(
          'transaction.payee.none_recorded'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return LockedField(
      label: 'transaction.field.payee'.tr,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payee.name ?? 'transaction.unknown'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (payee.bankName != null || payee.accountNumber != null)
                  Text(
                    [
                      if (payee.bankName != null) payee.bankName!,
                      if (payee.accountNumber != null) payee.accountNumber!,
                    ].join(' · '),
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
