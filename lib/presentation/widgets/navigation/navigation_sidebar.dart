import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/services/document_service.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/presentation/blocs/navigation/navigation_bloc.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class NavigationSidebar extends StatefulWidget {
  final VoidCallback? onNavigate;

  const NavigationSidebar({super.key, this.onNavigate});

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  UserProfile? _userProfile;
  File? _profileImageFile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await UserRepository().getCurrentUser();
      if (!mounted || user == null) return;

      final profile = UserProfile.fromCmmnUser(user);
      final imageFile = await DocumentService.instance.getProfileImageFile(
        profile.id,
      );

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _profileImageFile = imageFile;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  // Called by BlocListener when SidebarProfileLoaded is emitted
  void _applyProfileUpdate(UserProfile profile) async {
    final imageFile = await DocumentService.instance.getProfileImageFile(
      profile.id,
    );
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _profileImageFile = imageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listener: (context, state) {
        if (state is SidebarProfileLoaded) {
          _applyProfileUpdate(state.profile);
        }
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            _SidebarHeader(
              userProfile: _userProfile,
              profileImageFile: _profileImageFile,
              isLoading: _isLoadingProfile,
              onEditTap: () => _navigateTo(context, AppRoutes.profile),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _NavSection(
                      title: 'Profile',
                      items: [
                        _NavItemData(
                          icon: Icons.person_outline,
                          label: 'User Profile',
                          route: AppRoutes.profile,
                        ),
                      ],
                      activeRoute: context.read<NavigationBloc>().activeRoute,
                      onNavigate: _navigateTo,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NavSection(
                      title: 'Finance',
                      items: [
                        _NavItemData(
                          icon: Icons.savings,
                          label: 'Savings',
                          route: AppRoutes.savings,
                        ),
                        _NavItemData(
                          icon: Icons.pie_chart_outline,
                          label: 'Budgets',
                          route: AppRoutes.budgetList,
                        ),
                        _NavItemData(
                          icon: Icons.savings_outlined,
                          label: 'Budget Plans',
                          route: AppRoutes.budgetPlansList,
                        ),
                        _NavItemData(
                          icon: Icons.account_balance,
                          label: 'Money Storage',
                          route: AppRoutes.moneyStorage,
                        ),
                        _NavItemData(
                          icon: Icons.calendar_month_outlined,
                          label: 'Commitments',
                          route: AppRoutes.commitment,
                        ),
                        _NavItemData(
                          icon: Icons.people_outline,
                          label: 'Payees',
                          route: AppRoutes.payeeManagement,
                        ),
                        _NavItemData(
                          icon: Icons.category_outlined,
                          label: 'Categories',
                          route: AppRoutes.categoryManage,
                        ),
                      ],
                      activeRoute: context.read<NavigationBloc>().activeRoute,
                      onNavigate: _navigateTo,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NavSection(
                      title: 'App',
                      items: [
                        _NavItemData(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          route: AppRoutes.settings,
                        ),
                        _NavItemData(
                          icon: Icons.help_outline,
                          label: 'Help & FAQ',
                          onTap: () => _showComingSoon(context, 'Help & FAQ'),
                        ),
                        _NavItemData(
                          icon: Icons.feedback_outlined,
                          label: 'Send Feedback',
                          onTap: () =>
                              _showComingSoon(context, 'Send Feedback'),
                        ),
                      ],
                      activeRoute: context.read<NavigationBloc>().activeRoute,
                      onNavigate: _navigateTo,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            _SignOutButton(onTap: () => _showSignOutConfirmation(context)),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    context.read<NavigationBloc>().add(NavigateToScreenEvent(route));
    Future.delayed(const Duration(milliseconds: 150), () {
      if (context.mounted) {
        Navigator.pushNamed(context, route).then((_) {
          // Refresh sidebar profile when returning from profile screen
          if (route == AppRoutes.profile && context.mounted) {
            context.read<NavigationBloc>().add(RefreshSidebarProfileEvent());
          }
        });
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
      iconColor: Theme.of(context).colorScheme.tertiary,
      onConfirm: () {
        if (context.mounted) {
          showSnackBarMessage(
            context,
            'Signed out successfully',
            type: SnackBarMessageType.success,
          );
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
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'settings.feature_coming_soon'.trWith({"feature": feature}),
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
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.userProfile,
    required this.profileImageFile,
    required this.isLoading,
    required this.onEditTap,
  });

  final UserProfile? userProfile;
  final File? profileImageFile;
  final bool isLoading;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final name = userProfile?.name ?? 'Guest User';
    final email = userProfile?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary,
          ],
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
                _AvatarWidget(
                  name: name,
                  imageFile: profileImageFile,
                  isLoading: isLoading,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading ? '...' : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.isNotEmpty) ...[
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _EditProfileChip(onTap: onEditTap),
          ],
        ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.name,
    required this.imageFile,
    required this.isLoading,
  });

  final String name;
  final File? imageFile;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: isLoading
            ? Container(
                color: Colors.white.withValues(alpha: 0.2),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              )
            : imageFile != null
            ? Image.file(
                imageFile!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _InitialAvatar(name: name),
              )
            : _InitialAvatar(name: name),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _EditProfileChip extends StatelessWidget {
  const _EditProfileChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            Icon(Icons.edit, color: Colors.white, size: 14),
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
    );
  }
}

// ─── Nav section + items ──────────────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;

  const _NavItemData({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  });
}

class _NavSection extends StatelessWidget {
  const _NavSection({
    required this.title,
    required this.items,
    required this.activeRoute,
    required this.onNavigate,
  });

  final String title;
  final List<_NavItemData> items;
  final String activeRoute;
  final void Function(BuildContext, String) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...items.map(
          (item) => _NavItem(
            data: item,
            isActive: item.route != null && item.route == activeRoute,
            onNavigate: onNavigate,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onNavigate,
  });

  final _NavItemData data;
  final bool isActive;
  final void Function(BuildContext, String) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 0,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            data.icon,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: AppIconSize.sm,
          ),
        ),
        title: Text(
          data.label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 18,
              ),
        onTap: () {
          if (data.route != null) {
            onNavigate(context, data.route!);
          } else {
            data.onTap?.call();
          }
        },
      ),
    );
  }
}

// ─── Sign out ─────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.5),
              ),
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
}
