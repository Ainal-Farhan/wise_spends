import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/presentation/blocs/navigation/navigation_bloc.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Navigation Sidebar with Material 3 design
///
/// Provides quick access to:
/// - User Profile
/// - Finance Management features
/// - Settings
/// - Sign Out
class NavigationSidebar extends StatefulWidget {
  final VoidCallback? onNavigate;

  const NavigationSidebar({super.key, this.onNavigate});

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  UserProfile? _userProfile;

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
        setState(() {
          _userProfile = UserProfile.fromCmmnUser(profile);
        });
      }
    } catch (e) {
      // Ignore errors, will show default values
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _userProfile?.name ?? 'Guest User';
    final email = _userProfile?.email ?? 'guest@example.com';

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with user profile
          _buildHeader(context, name, email),

          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildSectionTitle('Profile'),
                  _buildNavItem(
                    context,
                    icon: Icons.person_outline,
                    label: 'User Profile',
                    route: AppRoutes.profile,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionTitle('Finance'),
                  _buildNavItem(
                    context,
                    icon: Icons.savings,
                    label: 'Savings',
                    route: AppRoutes.savings,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.pie_chart_outline,
                    label: 'Budgets',
                    route: AppRoutes.budgetList,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.savings_outlined,
                    label: 'Budget Plans',
                    route: AppRoutes.budgetPlansList,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.account_balance,
                    label: 'Money Storage',
                    route: AppRoutes.moneyStorage,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.calendar_month_outlined,
                    label: 'Commitments',
                    route: AppRoutes.commitment,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.people_outline,
                    label: 'Payees',
                    route: AppRoutes.payeeManagement,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.category_outlined,
                    label: 'Categories',
                    route: AppRoutes.categoryManage,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionTitle('App'),
                  _buildNavItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    route: AppRoutes.settings,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.help_outline,
                    label: 'Help & FAQ',
                    onTap: () => _showComingSoon(context, 'Help & FAQ'),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.feedback_outlined,
                    label: 'Send Feedback',
                    onTap: () => _showComingSoon(context, 'Send Feedback'),
                  ),
                ],
              ),
            ),
          ),

          // Sign out button
          _buildSignOutButton(context),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () {
                _navigateTo(context, AppRoutes.profile);
              },
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.primary, size: AppIconSize.sm),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {
        if (route != null) {
          _navigateTo(context, route);
        } else if (onTap != null) {
          onTap();
        }
      },
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showSignOutConfirmation(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    // Close sidebar first
    context.read<NavigationBloc>().add(NavigateToScreenEvent(route));

    // Navigate after a short delay to allow animation
    Future.delayed(const Duration(milliseconds: 150), () {
      if (context.mounted) {
        Navigator.pushNamed(context, route);
        widget.onNavigate?.call();
      }
    });
  }

  void _showSignOutConfirmation(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      icon: Icons.logout,
      iconColor: AppColors.tertiary,
      onConfirm: () {
        // Handle sign out logic here
        if (context.mounted) {
          showSnackBarMessage(
            context,
            'Signed out successfully',
            type: SnackBarMessageType.success,
          );
          // Navigate to login or handle auth state change
          // Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, ...);
        }
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_outlined, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$feature is coming soon!',
                style: const TextStyle(color: Colors.white),
              ),
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
}
