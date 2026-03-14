import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/app_locale.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../models/settings_models.dart';

/// Show language selection dialog
Future<String?> showLanguageSelectorDialog({
  required BuildContext context,
  required String currentLanguageCode,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => CustomDialog(
      config: CustomDialogConfig(
        title: 'settings.language'.tr,
        icon: Icons.language_outlined,
        iconColor: AppColors.tertiary,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageOption.options
              .where(
                (option) => AppLocale.values.any(
                  (locale) => option.code == locale.code,
                ),
              )
              .map((option) {
                final isSelected = option.code == currentLanguageCode;
                return _LanguageOptionTile(
                  option: option,
                  isSelected: isSelected,
                  onTap: () {
                    Navigator.pop(dialogContext, option.code);
                  },
                );
              })
              .toList(),
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

class _LanguageOptionTile extends StatelessWidget {
  final LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
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
              ? AppColors.tertiary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected
                ? AppColors.tertiary.withValues(alpha: 0.3)
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag emoji as avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Text(option.flag, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.nativeName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  Text(option.name, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.tertiary,
                size: AppIconSize.md,
              ),
          ],
        ),
      ),
    );
  }
}
