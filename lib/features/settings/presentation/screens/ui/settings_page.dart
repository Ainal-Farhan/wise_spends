import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/features/settings/presentation/screens/bloc/settings_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/dialogs/language_selector_dialog.dart';
import 'package:wise_spends/features/settings/presentation/screens/dialogs/theme_selector_dialog.dart';
import 'package:wise_spends/features/settings/presentation/screens/widgets/settings_profile_header.dart';
import 'package:wise_spends/features/settings/presentation/screens/widgets/settings_widgets.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;

  // Feature toggles (UI-only until backend support lands)
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  // Panel expansion state
  bool _isAccountExpanded = false;
  bool _isNotificationsExpanded = false;
  bool _isPreferencesExpanded = false;
  bool _isDataExpanded = false;
  bool _isSupportExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Trigger a fresh load so the BLoC always reflects persisted prefs.
    context.read<SettingsBloc>().add(const LoadSettingsEvent());
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserRepository().getCurrentUser();
      if (mounted && profile != null) {
        setState(() => _userProfile = UserProfile.fromCmmnUser(profile));
      }
    } catch (_) {}
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('settings.title'.tr),
        centerTitle: true,
        elevation: 0,
      ),
      // BlocListener handles side-effects (snackbars) while BlocBuilder
      // rebuilds only the parts of the UI that changed.
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listenWhen: (prev, curr) => curr is SettingsLoaded && prev != curr,
        listener: (context, state) {
          if (state is SettingsLoaded) {
            // Nothing to do here — side-effects (snackbars) are triggered from
            // the dialog callbacks so the user sees immediate feedback.
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading || state is SettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsError) {
            return Center(child: Text(state.message));
          }

          final loaded = state as SettingsLoaded;
          return _buildBody(loaded);
        },
      ),
    );
  }

  Widget _buildBody(SettingsLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SettingsProfileHeader(userProfile: _userProfile),
          const SizedBox(height: AppSpacing.lg),

          // ── Account & Security ──────────────────────────────────────────
          SettingsExpansionPanel(
            title: 'settings.account_security'.tr,
            description: 'settings.account_security_desc'.tr,
            leadingIcon: Icons.security_outlined,
            isExpanded: _isAccountExpanded,
            onExpansionChanged: (v) => setState(() => _isAccountExpanded = v),
            children: [
              SettingsTile(
                leadingIcon: Icons.person_outline,
                title: 'settings.edit_profile'.tr,
                subtitle: 'settings.profile_subtitle'.tr,
                hideTrailing: true,
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
              const Divider(height: 1, indent: 60),
              SettingsTile(
                leadingIcon: Icons.lock_outline,
                title: 'settings.privacy_security'.tr,
                subtitle: 'settings.privacy_security_desc'.tr,
                showComingSoon: true,
                hideTrailing: true,
                onTap: () => _showComingSoon('settings.privacy_security'.tr),
              ),
              const Divider(height: 1, indent: 60),
              SettingsToggleTile(
                leadingIcon: Icons.fingerprint,
                title: 'settings.biometric_login'.tr,
                subtitle: 'settings.biometric_subtitle'.tr,
                showComingSoon: true,
                isDisabled: true,
                value: _biometricEnabled,
                onChanged: (v) {
                  setState(() => _biometricEnabled = v);
                  _showComingSoon(
                    v
                        ? 'settings.biometric_enabled'.tr
                        : 'settings.biometric_disabled'.tr,
                  );
                },
              ),
            ],
          ),

          // ── Notifications ───────────────────────────────────────────────
          SettingsExpansionPanel(
            title: 'settings.notifications'.tr,
            description: 'settings.notifications_desc'.tr,
            leadingIcon: Icons.notifications_outlined,
            isExpanded: _isNotificationsExpanded,
            onExpansionChanged: (v) =>
                setState(() => _isNotificationsExpanded = v),
            children: [
              SettingsToggleTile(
                leadingIcon: Icons.notifications_active,
                title: 'settings.push_notifications'.tr,
                subtitle: 'settings.push_notifications_desc'.tr,
                showComingSoon: true,
                isDisabled: true,
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              const Divider(height: 1, indent: 60),
              SettingsTile(
                leadingIcon: Icons.calendar_month_outlined,
                title: 'settings.budget_reminders'.tr,
                subtitle: 'settings.budget_reminders_desc'.tr,
                showComingSoon: true,
                hideTrailing: true,
                isDisabled: !_notificationsEnabled,
                onTap: _notificationsEnabled
                    ? () => _showComingSoon('settings.budget_reminders'.tr)
                    : null,
              ),
            ],
          ),

          // ── Preferences ─────────────────────────────────────────────────
          SettingsExpansionPanel(
            title: 'settings.preferences'.tr,
            description: 'settings.preferences_desc'.tr,
            leadingIcon: Icons.tune,
            leadingBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            isExpanded: _isPreferencesExpanded,
            onExpansionChanged: (v) =>
                setState(() => _isPreferencesExpanded = v),
            children: [
              // Theme — live subtitle driven by BLoC state
              SettingsTile(
                leadingIcon: Icons.palette_outlined,
                title: 'settings.theme'.tr,
                subtitle: _themeSubtitle(state.themeMode),
                hideTrailing: true,
                onTap: () => _openThemeSelector(state.themeMode),
              ),
              const Divider(height: 1, indent: 60),
              // Language — live subtitle driven by BLoC state
              SettingsTile(
                leadingIcon: Icons.language_outlined,
                title: 'settings.language'.tr,
                subtitle: _languageSubtitle(state.languageCode),
                hideTrailing: true,
                onTap: () => _openLanguageSelector(state.languageCode),
              ),
              const Divider(height: 1, indent: 60),
              SettingsTile(
                leadingIcon: Icons.currency_exchange,
                title: 'settings.currency'.tr,
                subtitle: 'Malaysian Ringgit (RM)',
                showComingSoon: true,
                hideTrailing: true,
                onTap: () => _showComingSoon('settings.currency'.tr),
              ),
            ],
          ),

          // ── Data & Storage ───────────────────────────────────────────────
          SettingsExpansionPanel(
            title: 'settings.data_storage'.tr,
            description: 'settings.data_storage_desc'.tr,
            leadingIcon: Icons.storage_outlined,
            leadingBackgroundColor: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
            isExpanded: _isDataExpanded,
            onExpansionChanged: (v) => setState(() => _isDataExpanded = v),
            children: [
              SettingsTile(
                leadingIcon: Icons.backup_outlined,
                title: 'settings.backup_restore'.tr,
                subtitle: 'settings.backup_restore_desc'.tr,
                hideTrailing: true,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.backupRestore),
              ),
            ],
          ),

          // ── Support ──────────────────────────────────────────────────────
          SettingsExpansionPanel(
            title: 'settings.support'.tr,
            description: 'settings.support_desc'.tr,
            leadingIcon: Icons.help_outline,
            leadingBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            isExpanded: _isSupportExpanded,
            onExpansionChanged: (v) => setState(() => _isSupportExpanded = v),
            children: [
              SettingsTile(
                leadingIcon: Icons.help_center,
                title: 'settings.help_faq'.tr,
                subtitle: 'settings.help_faq_desc'.tr,
                showComingSoon: true,
                hideTrailing: true,
                onTap: () => _showComingSoon('settings.help_faq'.tr),
              ),
              const Divider(height: 1, indent: 60),
              SettingsTile(
                leadingIcon: Icons.feedback_outlined,
                title: 'settings.send_feedback'.tr,
                subtitle: 'settings.send_feedback_desc'.tr,
                showComingSoon: true,
                hideTrailing: true,
                onTap: () => _showComingSoon('settings.send_feedback'.tr),
              ),
              const Divider(height: 1, indent: 60),
              SettingsTile(
                leadingIcon: Icons.info_outline,
                title: 'settings.about_app'.tr,
                subtitle: 'Version 1.0.0',
                hideTrailing: true,
                onTap: _showAboutDialog,
              ),
            ],
          ),

          // ── Sign out ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton.destructive(
              label: 'settings.sign_out'.tr,
              onPressed: _showSignOutConfirmation,
              isFullWidth: true,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // ── Subtitle helpers (pure — no setState needed) ─────────────────────────

  String _themeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
      case ThemeMode.system:
        return 'Follow system';
    }
  }

  String _languageSubtitle(String code) {
    switch (code) {
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

  // ── Dialog launchers ──────────────────────────────────────────────────────

  Future<void> _openThemeSelector(ThemeMode current) async {
    final selected = await showThemeSelectorDialog(
      context: context,
      currentTheme: current,
    );
    if (selected == null || selected == current) return;

    // Dispatch → BLoC persists + emits to themeStream → MaterialApp rebuilds.
    if (mounted) {
      context.read<SettingsBloc>().add(ChangeThemeEvent(selected));
      _showSuccessSnackbar('Theme changed to ${_themeSubtitle(selected)}');
    }
  }

  Future<void> _openLanguageSelector(String currentCode) async {
    final selected = await showLanguageSelectorDialog(
      context: context,
      currentLanguageCode: currentCode,
    );
    if (selected == null || selected == currentCode) return;

    if (mounted) {
      context.read<SettingsBloc>().add(ChangeLanguageEvent(selected));
      _showSuccessSnackbar(
        'Language changed to ${_languageSubtitle(selected)}',
      );
    }
  }

  // ── Snackbar / dialog helpers ─────────────────────────────────────────────

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'settings.feature_coming_soon'.trWith({'feature': feature}),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: 'settings.sign_out'.tr,
          message: 'settings.sign_out_msg'.tr,
          icon: Icons.logout,
          iconColor: Theme.of(context).colorScheme.tertiary,
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(ctx),
            ),
            CustomDialogButton(
              text: 'settings.sign_out'.tr,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(ctx);
                _showSuccessSnackbar('settings.signed_out'.tr);
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
      applicationName: 'general.app_name'.tr,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: AppTouchTarget.min,
        height: AppTouchTarget.min,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.account_balance_wallet, color: Colors.white),
      ),
      children: [
        Text('settings.wise_spends_subtitle'.tr),
        const SizedBox(height: AppSpacing.md),
        Text('settings.copyright'.tr),
      ],
    );
  }
}
