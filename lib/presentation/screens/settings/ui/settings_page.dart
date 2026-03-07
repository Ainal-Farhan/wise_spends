import 'package:flutter/material.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/presentation/screens/commitment/commitment_management_screen.dart';
import 'package:wise_spends/presentation/screens/payee/payee_management_screen.dart';
import 'package:wise_spends/presentation/screens/settings/category_management_screen.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../widgets/settings_widgets.dart';
import '../dialogs/theme_selector_dialog.dart';
import '../dialogs/language_selector_dialog.dart';

/// Modern Settings Screen with Material 3 design and Expansion Panels
///
/// Features:
/// - Collapsible expansion panels for each section
/// - 'Coming Soon' badges for unimplemented features
/// - Interactive dialogs for selections
/// - Clean, organized layout
/// - Destructive action confirmations
/// - Profile header with actual user data
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;

  // Settings state
  ThemeMode _currentTheme = ThemeMode.system;
  String _currentLanguage = 'en';
  final String _currentCurrency = 'RM';

  // Feature toggles (for demo purposes)
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  // Track which panels are expanded
  bool _isAccountExpanded = false;
  bool _isNotificationsExpanded = false;
  bool _isFinanceExpanded = false;
  bool _isPreferencesExpanded = false;
  bool _isDataExpanded = false;
  bool _isSupportExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final repository = UserRepository();
      final profile = await repository.getCurrentUser();
      if (mounted && profile != null) {
        setState(() => _userProfile = profile);
      }
    } catch (e) {
      // Ignore errors, will show default values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            const SizedBox(height: AppSpacing.lg),

            // Account & Security Section
            _buildExpansionPanel(
              id: 'account',
              title: 'Account & Security',
              description: 'Manage your account settings and security',
              leadingIcon: Icons.security_outlined,
              isExpanded: _isAccountExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isAccountExpanded = expanded);
              },
              children: [
                SettingsTile(
                  leadingIcon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Edit your personal information',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.lock_outline,
                  title: 'Privacy & Security',
                  subtitle: 'Password, biometrics, and privacy',
                  showComingSoon: true,
                  onTap: () {
                    _showComingSoonMessage(context, 'Privacy & Security');
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsToggleTile(
                  leadingIcon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face to unlock',
                  value: _biometricEnabled,
                  onChanged: (value) {
                    setState(() => _biometricEnabled = value);
                    _showComingSoonMessage(
                      context,
                      value ? 'Biometric enabled' : 'Biometric disabled',
                    );
                  },
                ),
              ],
            ),

            // Notifications Section
            _buildExpansionPanel(
              id: 'notifications',
              title: 'Notifications',
              description: 'Control how you receive notifications',
              leadingIcon: Icons.notifications_outlined,
              isExpanded: _isNotificationsExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isNotificationsExpanded = expanded);
              },
              children: [
                SettingsToggleTile(
                  leadingIcon: Icons.notifications_active,
                  title: 'Push Notifications',
                  subtitle: 'Receive transaction alerts and reminders',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.calendar_month_outlined,
                  title: 'Budget Reminders',
                  subtitle: 'Get notified when approaching budget limits',
                  showComingSoon: true,
                  isDisabled: !_notificationsEnabled,
                  onTap: () {
                    if (_notificationsEnabled) {
                      _showComingSoonMessage(context, 'Budget Reminders');
                    }
                  },
                ),
              ],
            ),

            // Finance Management Section
            _buildExpansionPanel(
              id: 'finance',
              title: 'Finance Management',
              description: 'Manage your budgets, accounts, and categories',
              leadingIcon: Icons.attach_money,
              leadingBackgroundColor: AppColors.tertiaryContainer,
              isExpanded: _isFinanceExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isFinanceExpanded = expanded);
              },
              children: [
                SettingsTile(
                  leadingIcon: Icons.savings,
                  title: 'Savings',
                  subtitle: 'Manage your savings goals',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.savings);
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.account_balance_wallet,
                  title: 'Budgets',
                  subtitle: 'Track spending limits and budgets',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.budgetList);
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.account_balance,
                  title: 'Money Storage',
                  subtitle: 'Manage savings and storage accounts',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.moneyStorage);
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.calendar_month_outlined,
                  title: 'Commitments',
                  subtitle: 'Recurring expenses and bills',
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
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.people_outline,
                  title: 'Payees',
                  subtitle: 'Payment recipients for transfers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PayeeManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.category_outlined,
                  title: 'Categories',
                  subtitle: 'Transaction categories and tags',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryManagementScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Preferences Section
            _buildExpansionPanel(
              id: 'preferences',
              title: 'Preferences',
              description: 'Customize your app experience',
              leadingIcon: Icons.tune,
              leadingBackgroundColor: AppColors.secondaryContainer,
              isExpanded: _isPreferencesExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isPreferencesExpanded = expanded);
              },
              children: [
                SettingsTile(
                  leadingIcon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: _getThemeSubtitle(),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => _showThemeSelector(),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: _getLanguageSubtitle(),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  showComingSoon: true,
                  onTap: () => _showLanguageSelector(),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.currency_exchange,
                  title: 'Currency',
                  subtitle: _getCurrencySubtitle(),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  showComingSoon: true,
                  onTap: () {
                    _showComingSoonMessage(context, 'Currency Settings');
                  },
                ),
              ],
            ),

            // Data & Storage Section
            _buildExpansionPanel(
              id: 'data',
              title: 'Data & Storage',
              description: 'Backup, export, and manage your data',
              leadingIcon: Icons.storage_outlined,
              leadingBackgroundColor: AppColors.warning.withValues(alpha: 0.1),
              isExpanded: _isDataExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isDataExpanded = expanded);
              },
              children: [
                SettingsTile(
                  leadingIcon: Icons.backup_outlined,
                  title: 'Backup & Restore',
                  subtitle: 'Save and restore your data',
                  showComingSoon: true,
                  onTap: () {
                    _showComingSoonMessage(context, 'Backup & Restore');
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.file_download_outlined,
                  title: 'Export Data',
                  subtitle: 'Export transactions to CSV or PDF',
                  showComingSoon: true,
                  onTap: () {
                    _showComingSoonMessage(context, 'Export Data');
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.delete_outline,
                  title: 'Clear All Data',
                  subtitle: 'Permanently delete all local data',
                  isDestructive: true,
                  onTap: () => _showClearDataConfirmation(),
                ),
              ],
            ),

            // Support Section
            _buildExpansionPanel(
              id: 'support',
              title: 'Support',
              description: 'Get help and learn more about the app',
              leadingIcon: Icons.help_outline,
              leadingBackgroundColor: AppColors.info.withValues(alpha: 0.1),
              isExpanded: _isSupportExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _isSupportExpanded = expanded);
              },
              children: [
                SettingsTile(
                  leadingIcon: Icons.help_center,
                  title: 'Help & FAQ',
                  subtitle: 'Common questions and answers',
                  showComingSoon: true,
                  onTap: () {
                    _showComingSoonMessage(context, 'Help & FAQ');
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts with us',
                  showComingSoon: true,
                  onTap: () {
                    _showComingSoonMessage(context, 'Send Feedback');
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  leadingIcon: Icons.info_outline,
                  title: 'About WiseSpends',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAboutDialog(),
                ),
              ],
            ),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton.destructive(
                label: 'Sign Out',
                onPressed: _showSignOutConfirmation,
                isFullWidth: true,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI Builders
  // ---------------------------------------------------------------------------

  Widget _buildProfileHeader() {
    final name = _userProfile?.name ?? 'Guest User';
    final email = _userProfile?.email ?? 'guest@example.com';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
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

  Widget _buildExpansionPanel({
    required String id,
    required String title,
    required String description,
    required IconData leadingIcon,
    Color? leadingBackgroundColor,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              onExpansionChanged(!isExpanded);
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: leadingBackgroundColor ??
                          AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: leadingBackgroundColor != null
                          ? AppColors.primary
                          : AppColors.primary,
                      size: AppIconSize.sm,
                    ),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content (shown when expanded)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.md),
                bottomRight: Radius.circular(AppRadius.md),
              ),
              child: Column(children: children),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _getThemeSubtitle() {
    switch (_currentTheme) {
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
      case ThemeMode.system:
        return 'Follow system';
    }
  }

  String _getLanguageSubtitle() {
    switch (_currentLanguage) {
      case 'en':
        return 'English';
      case 'ms':
        return 'Bahasa Melayu';
      case 'zh':
        return '简体中文';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  String _getCurrencySubtitle() {
    return 'Malaysian Ringgit ($_currentCurrency)';
  }

  void _showComingSoonMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('$feature feature coming soon!'),
            ),
          ],
        ),
        backgroundColor: AppColors.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _showThemeSelector() async {
    final themeMode = await showThemeSelectorDialog(
      context: context,
      currentTheme: _currentTheme,
    );

    if (themeMode != null && themeMode != _currentTheme) {
      setState(() => _currentTheme = themeMode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Theme changed to ${_getThemeSubtitle()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  Future<void> _showLanguageSelector() async {
    final languageCode = await showLanguageSelectorDialog(
      context: context,
      currentLanguageCode: _currentLanguage,
    );

    if (languageCode != null && languageCode != _currentLanguage) {
      setState(() => _currentLanguage = languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language changed to ${_getLanguageSubtitle()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    }
  }

  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Clear All Data?',
          message:
              'This will permanently delete all your local data including transactions, budgets, and settings. This action cannot be undone.',
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Clear All',
              isDestructive: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Sign Out',
          message:
              'Are you sure you want to sign out? You will need to sign in again to access your data.',
          icon: Icons.logout,
          iconColor: AppColors.tertiary,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Sign Out',
              isDestructive: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
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
