import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/features/auth/presentation/bloc/profile_bloc.dart';
import 'package:wise_spends/features/auth/presentation/bloc/profile_event.dart';
import 'package:wise_spends/features/auth/presentation/bloc/profile_state.dart';
import 'package:wise_spends/features/auth/presentation/screens/widgets/profile_account_info_card.dart';
import 'package:wise_spends/features/auth/presentation/screens/widgets/profile_avatar.dart';
import 'package:wise_spends/features/auth/presentation/screens/widgets/profile_danger_zone.dart';
import 'package:wise_spends/features/auth/presentation/screens/widgets/profile_form_fields.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Profile screen – purely orchestrates BLoC + child widgets.
///
/// All UI sub-sections live in their own widget files under
/// `features/auth/presentation/widgets/`.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(UserRepository())..add(LoadProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() => _LoadingScaffold(),
            ProfileImageUploading(:final profile) => _buildScaffold(
              context,
              profile,
              isUploadingImage: true,
            ),
            ProfileLoaded(:final profile) => _syncControllers(
              profile,
              then: () {
                return _buildScaffold(
                  context,
                  profile,
                  profileImageLoaded: true,
                  profileImageFile: state.profileImageFile,
                );
              },
            ),
            ProfileError(:final message) => _ErrorScaffold(message: message),
            _ => _LoadingScaffold(),
          };
        },
      ),
    );
  }

  // ─── State listener ────────────────────────────────────────────────────────

  void _handleStateChanges(BuildContext context, ProfileState state) {
    if (state is ProfileUpdated) {
      _showSnackBar(
        context,
        message: 'profile.updated_success'.tr,
        icon: Icons.check_circle,
        color: AppColors.success,
      );
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) context.read<ProfileBloc>().add(LoadProfileEvent());
      });
    } else if (state is ProfileImageUpdated) {
      _showSnackBar(
        context,
        message: 'Photo updated successfully',
        icon: Icons.check_circle,
        color: AppColors.success,
      );
    } else if (state is ProfileError) {
      _showSnackBar(
        context,
        message: state.message,
        icon: Icons.error_outline,
        color: AppColors.error,
      );
    }
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  // ─── Controller sync ───────────────────────────────────────────────────────

  Widget _syncControllers(
    UserProfile profile, {
    required Widget Function() then,
  }) {
    if (_nameController.text.isEmpty) _nameController.text = profile.name;
    if (_emailController.text.isEmpty && profile.email != null) {
      _emailController.text = profile.email!;
    }
    if (_phoneController.text.isEmpty && profile.phone != null) {
      _phoneController.text = profile.phone!;
    }
    if (_occupationController.text.isEmpty && profile.occupation != null) {
      _occupationController.text = profile.occupation!;
    }
    if (_addressController.text.isEmpty && profile.address != null) {
      _addressController.text = profile.address!;
    }
    return then();
  }

  // ─── Main scaffold ─────────────────────────────────────────────────────────

  Widget _buildScaffold(
    BuildContext context,
    UserProfile profile, {
    bool isUploadingImage = false,
    bool profileImageLoaded = false,
    dynamic profileImageFile,
  }) {
    return Scaffold(
      appBar: _ProfileAppBar(
        profile: profile,
        onMoreOptions: () => _showMoreOptions(context, profile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ──
              ProfileAvatar(
                profile: profile,
                storedImageFile: profileImageFile,
                isUploading: isUploadingImage,
                onPickImage: () => _showImageSourceSheet(context),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Personal info form ──
              ProfileFormFields(
                nameController: _nameController,
                emailController: _emailController,
                phoneController: _phoneController,
                occupationController: _occupationController,
                addressController: _addressController,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Save ──
              AppButton.primary(
                label: 'profile.save_changes'.tr,
                icon: Icons.save_outlined,
                isFullWidth: true,
                onPressed: () => _updateProfile(context, profile),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Account info ──
              ProfileAccountInfoCard(profile: profile),
              const SizedBox(height: AppSpacing.xxl),

              // ── Danger zone ──
              ProfileDangerZone(
                onDeleteAccount: () =>
                    _showComingSoon(context, 'profile.account_deletion'.tr),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Profile update ────────────────────────────────────────────────────────

  void _updateProfile(BuildContext context, UserProfile current) {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        context,
        message: 'profile.fix_errors'.tr,
        icon: Icons.error_outline,
        color: AppColors.error,
      );
      return;
    }

    final updated = current.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().nullIfEmpty,
      phone: _phoneController.text.trim().nullIfEmpty,
      occupation: _occupationController.text.trim().nullIfEmpty,
      address: _addressController.text.trim().nullIfEmpty,
      dateUpdated: DateTime.now(),
    );

    context.read<ProfileBloc>().add(UpdateProfileEvent(updated));
  }

  // ─── Image picking ─────────────────────────────────────────────────────────

  void _showImageSourceSheet(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    final state = bloc.state;
    final hasImage = state is ProfileLoaded && state.profileImageFile != null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text('profile.take_photo'.tr),
              onTap: () {
                Navigator.pop(context);
                bloc.add(const PickProfileImageEvent(ImageSource.camera));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('profile.choose_gallery'.tr),
              onTap: () {
                Navigator.pop(context);
                bloc.add(const PickProfileImageEvent(ImageSource.gallery));
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  'profile.remove_photo'.tr,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  bloc.add(RemoveProfileImageEvent());
                },
              ),
          ],
        ),
      ),
    );
  }

  // ─── More options ──────────────────────────────────────────────────────────

  void _showMoreOptions(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text('profile.change_password'.tr),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text('profile.share_profile'.tr),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'profile.share_profile'.tr);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text('profile.export_profile'.tr),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'profile.export_profile'.tr);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPw = TextEditingController();
    final newPw = TextEditingController();
    final confirmPw = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'profile.change_password'.tr,
          icon: Icons.lock_outline,
          iconColor: AppColors.tertiary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'profile.current_password'.tr,
                controller: currentPw,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'profile.new_password'.tr,
                controller: newPw,
                prefixIcon: Icons.lock_outlined,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'profile.confirm_password'.tr,
                controller: confirmPw,
                prefixIcon: Icons.lock_outlined,
                obscureText: true,
              ),
            ],
          ),
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'general.save'.tr,
              isDefault: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                _showComingSoon(context, 'profile.password_change'.tr);
              },
            ),
          ],
        ),
      ),
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
                'settings.feature_coming_soon'.trWith({'feature': feature}),
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

// ─── Helper extension ─────────────────────────────────────────────────────────

extension _StringX on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar({required this.profile, required this.onMoreOptions});

  final UserProfile profile;
  final VoidCallback onMoreOptions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('profile.title'.tr),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onMoreOptions,
          tooltip: 'More options',
        ),
      ],
    );
  }
}

// ─── Loading scaffold ─────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

// ─── Error scaffold ───────────────────────────────────────────────────────────

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppIconSize.hero,
                color: AppColors.secondary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('profile.something_wrong'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 200,
                child: AppButton.primary(
                  label: 'general.retry'.tr,
                  onPressed: () =>
                      context.read<ProfileBloc>().add(LoadProfileEvent()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
