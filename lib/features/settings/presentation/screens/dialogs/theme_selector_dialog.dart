import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../models/settings_models.dart';

/// Show theme selection dialog
Future<ThemeMode?> showThemeSelectorDialog({
  required BuildContext context,
  required ThemeMode currentTheme,
}) {
  return showDialog<ThemeMode>(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: 'settings.theme'.tr,
        icon: Icons.palette_outlined,
        iconColor: AppColors.primary,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeOption.options.map((option) {
            final isSelected = _getThemeModeFromId(option.id) == currentTheme;
            return _ThemeOptionTile(
              option: option,
              isSelected: isSelected,
              onTap: () {
                Navigator.pop(dialogContext, option.themeMode);
              },
            );
          }).toList(),
        ),
        buttons: [
          CustomDialogButton(
            text: 'general.cancel'.tr,
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    ),
  );
}

class _ThemeOptionTile extends StatelessWidget {
  final ThemeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                option.icon,
                color: AppColors.primary,
                size: AppIconSize.sm,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: AppIconSize.md,
              ),
          ],
        ),
      ),
    );
  }
}

ThemeMode _getThemeModeFromId(String id) {
  switch (id) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.system;
  }
}
