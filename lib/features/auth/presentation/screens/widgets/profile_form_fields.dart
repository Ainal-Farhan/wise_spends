import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Renders all editable profile form fields grouped under a labelled section.
class ProfileFormFields extends StatelessWidget {
  const ProfileFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.occupationController,
    required this.addressController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController occupationController;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: 'profile.personal_info'.tr,
          subtitle: 'profile.personal_info_desc'.tr,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: 'profile.full_name'.tr,
          controller: nameController,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'profile.full_name_required'.tr;
            }
            if (value.length < 2) return 'profile.full_name_short'.tr;
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: 'profile.email_address'.tr,
          controller: emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: AppTextFieldKeyboardType.email,
        ),
        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: 'profile.phone_number'.tr,
          controller: phoneController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: AppTextFieldKeyboardType.phone,
        ),
        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: 'profile.occupation'.tr,
          controller: occupationController,
          prefixIcon: Icons.work_outline,
          hint: 'profile.occupation_hint'.tr,
        ),
        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: 'profile.address'.tr,
          controller: addressController,
          prefixIcon: Icons.home_outlined,
          hint: 'profile.address_hint'.tr,
          maxLines: 2,
        ),
      ],
    );
  }
}

// ─── Shared section header ───────────────────────────────────────────────────

/// Reusable titled section header used throughout the profile screen.
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
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
            child: Icon(icon, color: AppColors.primary, size: AppIconSize.sm),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
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
