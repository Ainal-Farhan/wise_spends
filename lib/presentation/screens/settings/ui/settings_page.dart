import 'package:flutter/material.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../category_management_screen.dart';
import '../../commitment/commitment_management_screen.dart';

/// Settings Screen
/// Features:
/// - Grouped sections with icons
/// - Consistent list tile style
/// - Destructive actions in red
/// - Version info at bottom
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSection(
              context,
              title: 'Account',
              children: [
                _buildSettingsTile(
                  context,
                  leading: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Manage your personal information',
                  onTap: () {
                    // Navigate to profile
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Password, biometrics, and data',
                  onTap: () {
                    // Navigate to security
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {
                    // Navigate to notifications
                  },
                ),
              ],
            ),

            // App Preferences Section
            _buildSection(
              context,
              title: 'Preferences',
              children: [
                _buildSettingsTile(
                  context,
                  leading: Icons.calendar_month_outlined,
                  title: 'Commitments',
                  subtitle: 'Manage recurring expenses and bills',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CommitmentManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.category_outlined,
                  title: 'Manage Categories',
                  subtitle: 'Add, edit, or delete transaction categories',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryManagementScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: 'Light, Dark, System',
                  trailing: const Text(
                    'System',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    // Navigate to theme settings
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  trailing: const Text(
                    'English',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    // Navigate to language settings
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.currency_exchange,
                  title: 'Currency',
                  subtitle: 'Malaysian Ringgit (RM)',
                  trailing: const Text(
                    'RM',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    // Navigate to currency settings
                  },
                ),
              ],
            ),

            // Data & Storage Section
            _buildSection(
              context,
              title: 'Data & Storage',
              children: [
                _buildSettingsTile(
                  context,
                  leading: Icons.backup_outlined,
                  title: 'Backup & Restore',
                  subtitle: 'Save and restore your data',
                  onTap: () {
                    // Navigate to backup
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.file_download_outlined,
                  title: 'Export Data',
                  subtitle: 'Export transactions to CSV',
                  onTap: () {
                    // Navigate to export
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.delete_outline,
                  title: 'Clear Data',
                  subtitle: 'Remove all local data',
                  isDestructive: true,
                  onTap: () {
                    _showClearDataConfirmation(context);
                  },
                ),
              ],
            ),

            // Support Section
            _buildSection(
              context,
              title: 'Support',
              children: [
                _buildSettingsTile(
                  context,
                  leading: Icons.help_outline,
                  title: 'Help & FAQ',
                  subtitle: 'Get help and answers',
                  onTap: () {
                    // Navigate to help
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts with us',
                  onTap: () {
                    // Navigate to feedback
                  },
                ),
                _buildSettingsTile(
                  context,
                  leading: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),

            // Logout / Sign Out Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton.destructive(
                label: 'Sign Out',
                onPressed: () {
                  _showSignOutConfirmation(context);
                },
                isFullWidth: true,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      minLeadingWidth: AppTouchTarget.min,
      leading: Container(
        width: AppTouchTarget.min,
        height: AppTouchTarget.min,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          leading,
          color: isDestructive ? AppColors.secondary : AppColors.primary,
          size: AppIconSize.md,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.secondary : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
          : null,
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your local data including transactions, budgets, and settings. This action cannot be undone.',
        ),
        actions: [
          AppButton.text(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          AppButton.destructive(
            label: 'Clear All',
            onPressed: () {
              Navigator.pop(context);
              // Clear data logic
            },
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? You will need to sign in again to access your data.',
        ),
        actions: [
          AppButton.text(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          AppButton.destructive(
            label: 'Sign Out',
            onPressed: () {
              Navigator.pop(context);
              // Sign out logic
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'WiseSpends',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: AppTouchTarget.min,
        height: AppTouchTarget.min,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.account_balance_wallet, color: Colors.white),
      ),
      children: [
        const Text('WiseSpends - Smart Budget Tracking'),
        const SizedBox(height: AppSpacing.md),
        const Text('© 2026 WiseSpends. All rights reserved.'),
      ],
    );
  }
}
