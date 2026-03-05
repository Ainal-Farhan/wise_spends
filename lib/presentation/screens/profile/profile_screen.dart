import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/data/repositories/common/impl/user_repository.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/presentation/blocs/profile/profile_bloc.dart';
import 'package:wise_spends/presentation/blocs/profile/profile_event.dart';
import 'package:wise_spends/presentation/blocs/profile/profile_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Enhanced Profile Screen
/// Features:
/// - Avatar with initial
/// - Form with validation
/// - Account information section
/// - Loading and error states
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
              context.read<ProfileBloc>().add(LoadProfileEvent());
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
            _nameController.text = state.profile.name;
            _emailController.text = state.profile.email ?? '';
            _phoneController.text = state.profile.phone ?? '';

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
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: AppAvatar(
                  label: profile.name,
                  size: AppAvatarSize.hero,
                  backgroundColor: AppColors.primary,
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Personal Information Section
              SectionHeader(
                title: 'Personal Information',
                subtitle: 'Update your personal details',
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                label: 'Name',
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email,
                keyboardType: AppTextFieldKeyboardType.email,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Phone',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                keyboardType: AppTextFieldKeyboardType.phone,
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton.primary(
                label: 'Update Profile',
                onPressed: () => _updateProfile(context),
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Account Information Section
              SectionHeader(
                title: 'Account Information',
                subtitle: 'Your account details',
              ),
              const SizedBox(height: AppSpacing.lg),

              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Member Since:',
                      _formatDate(profile.dateCreated),
                    ),
                    const Divider(height: AppSpacing.xl),
                    _buildInfoRow(
                      'Last Updated:',
                      _formatDate(profile.dateUpdated),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
      final updatedProfile = UserProfile(
        id: context.read<ProfileBloc>().state is ProfileLoaded
            ? (context.read<ProfileBloc>().state as ProfileLoaded).profile.id
            : '',
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        dateCreated: context.read<ProfileBloc>().state is ProfileLoaded
            ? (context.read<ProfileBloc>().state as ProfileLoaded)
                  .profile
                  .dateCreated
            : DateTime.now(),
        dateUpdated: DateTime.now(),
      );

      context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile));
    }
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
