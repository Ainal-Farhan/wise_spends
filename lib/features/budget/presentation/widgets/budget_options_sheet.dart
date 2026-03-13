// FIXED: Implemented budget options sheet with full functionality
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Budget options bottom sheet - Edit, Delete, Toggle Active
class BudgetOptionsSheet extends StatelessWidget {
  final BudgetEntity budget;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final VoidCallback? onDelete;

  const BudgetOptionsSheet({
    super.key,
    required this.budget,
    this.onEdit,
    this.onToggleActive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            budget.name,
            style: AppTextStyles.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Options
          _OptionTile(
            icon: Icons.edit,
            label: 'general.edit'.tr,
            onTap: onEdit ?? () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: budget.isActive ? Icons.visibility_off : Icons.visibility,
            label: budget.isActive ? 'budgets.deactivate'.tr : 'budgets.activate'.tr,
            onTap: onToggleActive ?? () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: Icons.delete_outline,
            label: 'general.delete'.tr,
            labelColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _confirmDelete(context),
          ),
          const SizedBox(height: AppSpacing.md),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: AppButton.secondary(
              label: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Navigator.pop(context);
    showConfirmDialog(
      context: context,
      title: 'budgets.delete'.tr,
      message: 'budgets.delete_msg'.trWith({'name': budget.name}),
      confirmText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      onConfirm: onDelete,
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.labelColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textPrimary,
        size: AppIconSize.md,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
