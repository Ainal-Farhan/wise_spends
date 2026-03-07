import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/presentation/blocs/profile/profile_bloc.dart';
import 'package:wise_spends/presentation/blocs/profile/profile_event.dart';
import 'package:wise_spends/presentation/blocs/profile/profile_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Enhanced Profile Screen with Modern Material 3 Design
///
/// Features:
/// - Avatar with image upload capability
/// - Form with validation
/// - Profile statistics section
/// - Account information section
/// - Loading and error states
/// - Success feedback
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

  File? _profileImage;
  final _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(UserRepository())..add(LoadProfileEvent()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Profile updated successfully'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );

            Timer(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<ProfileBloc>().add(LoadProfileEvent());
              }
            });
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const _ProfileScreenLoading();
          } else if (state is ProfileLoaded) {
            if (_nameController.text.isEmpty) {
              _nameController.text = state.profile.name;
            }
            if (_emailController.text.isEmpty && state.profile.email != null) {
              _emailController.text = state.profile.email!;
            }
            if (_phoneController.text.isEmpty && state.profile.phone != null) {
              _phoneController.text = state.profile.phone!;
            }
            if (_occupationController.text.isEmpty && state.profile.occupation != null) {
              _occupationController.text = state.profile.occupation!;
            }
            if (_addressController.text.isEmpty && state.profile.address != null) {
              _addressController.text = state.profile.address!;
            }

            return _buildProfileForm(context, state.profile);
          } else if (state is ProfileError) {
            return _buildErrorState(context, state.message);
          } else {
            return const _ProfileScreenLoading();
          }
        },
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, UserProfile profile) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context, profile),
            tooltip: 'More options',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              _buildAvatarSection(profile),
              const SizedBox(height: AppSpacing.xxl),

              // Personal Information Section
              _buildSectionHeader(
                title: 'Personal Information',
                subtitle: 'Update your personal details',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Full Name *',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Email Address',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: AppTextFieldKeyboardType.email,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Phone Number',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: AppTextFieldKeyboardType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Occupation',
                controller: _occupationController,
                prefixIcon: Icons.work_outline,
                hint: 'e.g., Software Engineer, Student',
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Address',
                controller: _addressController,
                prefixIcon: Icons.home_outlined,
                hint: 'e.g., 123 Main St, Kuala Lumpur',
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Save Button
              AppButton.primary(
                label: 'Save Changes',
                onPressed: () => _updateProfile(context),
                isFullWidth: true,
                icon: Icons.save_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Account Information Section
              _buildSectionHeader(
                title: 'Account Information',
                subtitle: 'Your account details',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildInfoCard(profile),
              const SizedBox(height: AppSpacing.xxl),

              // Danger Zone
              _buildDangerZone(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(UserProfile profile) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _profileImage != null
                      ? Colors.transparent
                      : AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              // Upload button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploadingImage
                      ? Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(8),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showImageSourceDialog,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: _showImageSourceDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _profileImage != null
                        ? 'Change photo'
                        : 'Add photo',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
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
            child: Icon(
              icon,
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

  Widget _buildInfoCard(UserProfile profile) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Member Since:',
            _formatDate(profile.dateCreated),
            Icons.calendar_today_outlined,
          ),
          const Divider(height: AppSpacing.xl),
          _buildInfoRow(
            'Last Updated:',
            _formatDate(profile.dateUpdated),
            Icons.update_outlined,
          ),
          const Divider(height: AppSpacing.xl),
          _buildInfoRow(
            'User ID:',
            profile.id,
            Icons.badge_outlined,
            isMonospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppIconSize.sm,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: isMonospace ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.secondary,
                size: AppIconSize.md,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Danger Zone',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Irreversible actions regarding your account',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.destructive(
            label: 'Delete Account',
            onPressed: () => _showDeleteAccountDialog(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _updateProfile(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final loadedState = context.read<ProfileBloc>().state;
      if (loadedState is! ProfileLoaded) return;

      final updatedProfile = UserProfile(
        id: loadedState.profile.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        occupation: _occupationController.text.trim().isEmpty
            ? null
            : _occupationController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        profileImageUrl: _profileImage != null
            ? _profileImage!.path
            : loadedState.profile.profileImageUrl,
        dateCreated: loadedState.profile.dateCreated,
        dateUpdated: DateTime.now(),
      );

      context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _profileImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isUploadingImage = true);

    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _showMoreOptions(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                _showShareProfile(context, profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export Profile Data'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonMessage(context, 'Export Profile Data');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Change Password',
          icon: Icons.lock_outline,
          iconColor: AppColors.tertiary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Current Password',
                controller: currentPasswordController,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'New Password',
                controller: newPasswordController,
                prefixIcon: Icons.lock_outlined,
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Confirm New Password',
                controller: confirmPasswordController,
                prefixIcon: Icons.lock_outlined,
                obscureText: true,
              ),
            ],
          ),
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Change',
              isDefault: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                _showComingSoonMessage(context, 'Password Change');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: CustomDialog(
          config: CustomDialogConfig(
            title: 'Delete Account?',
            message:
                'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.secondary,
            buttons: [
              CustomDialogButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(dialogContext),
              ),
              CustomDialogButton(
                text: 'Delete Account',
                isDestructive: true,
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _showComingSoonMessage(context, 'Account Deletion');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareProfile(BuildContext context, UserProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile: ${profile.name}'),
        backgroundColor: AppColors.info,
        action: SnackBarAction(
          label: 'Share',
          textColor: Colors.white,
          onPressed: () {
            _showComingSoonMessage(context, 'Share Profile');
          },
        ),
      ),
    );
  }

  void _showComingSoonMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction_outlined, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
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

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppIconSize.hero,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Oops! Something went wrong', style: AppTextStyles.h3),
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
                label: 'Retry',
                onPressed: () {
                  context.read<ProfileBloc>().add(LoadProfileEvent());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class _ProfileScreenLoading extends StatelessWidget {
  const _ProfileScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
