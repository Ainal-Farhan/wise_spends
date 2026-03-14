import 'package:flutter/material.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

/// Gradient profile card shown at the top of the Settings screen.
/// Tapping the edit icon navigates to the profile edit route.
class SettingsProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;

  const SettingsProfileHeader({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final name = userProfile?.name ?? 'Guest User';
    final email = userProfile?.email ?? 'guest@example.com';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name & email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Edit button
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: AppIconSize.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
