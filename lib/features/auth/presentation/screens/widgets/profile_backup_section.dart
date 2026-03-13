import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/features/auth/presentation/bloc/profile_bloc.dart';
import 'package:wise_spends/features/auth/presentation/bloc/profile_event.dart';
import 'package:wise_spends/features/auth/presentation/bloc/profile_state.dart';
import 'package:wise_spends/features/auth/presentation/screens/widgets/profile_form_fields.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Backup & Restore section rendered inside the profile screen.
///
/// Handles its own BLoC state subscription so the parent screen
/// doesn't need to worry about backup state transitions.
class ProfileBackupSection extends StatelessWidget {
  const ProfileBackupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: 'Backup & Restore',
          subtitle: 'Export your data or migrate to another device',
          icon: Icons.backup_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),

        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackupInfoRow(),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: _BackupButton(
                      label: 'Create Backup',
                      icon: Icons.save_outlined,
                      onPressed: (context) {
                        context.read<ProfileBloc>().add(
                          const CreateBackupEvent(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _BackupButton(
                      label: 'Share Backup',
                      icon: Icons.share_outlined,
                      onPressed: (context) {
                        context.read<ProfileBloc>().add(
                          const CreateBackupEvent(share: true),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.secondary(
                label: 'Restore from Backup',
                icon: Icons.restore_outlined,
                isFullWidth: true,
                onPressed: () => _showRestoreSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRestoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: const _RestoreBottomSheet(),
      ),
    );
  }
}

class _BackupInfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Backups include all your files and data. '
              'Use them to migrate to a new device.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupButton extends StatelessWidget {
  const _BackupButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final void Function(BuildContext) onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (_, s) =>
          s is ProfileBackupInProgress || s is ProfileBackupSuccess,
      builder: (context, state) {
        final loading = state is ProfileBackupInProgress;
        return AppButton.primary(
          label: label,
          icon: icon,
          isFullWidth: true,
          isLoading: loading,
          onPressed: loading ? null : () => onPressed(context),
        );
      },
    );
  }
}

class _RestoreBottomSheet extends StatefulWidget {
  const _RestoreBottomSheet();

  @override
  State<_RestoreBottomSheet> createState() => _RestoreBottomSheetState();
}

class _RestoreBottomSheetState extends State<_RestoreBottomSheet> {
  bool _isPicking = false;

  Future<void> _pickAndRestore() async {
    setState(() => _isPicking = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['zip', 'json', 'sqlite'],
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        // User cancelled — just close
        Navigator.pop(context);
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        Navigator.pop(context);
        return;
      }

      Navigator.pop(context);
      context.read<ProfileBloc>().add(RestoreBackupEvent(filePath));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Restore from Backup',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select a .zip, .json, or .sqlite backup file from your device. '
            'Existing data will be merged.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.primary(
            label: _isPicking
                ? 'Opening file picker…'
                : 'Browse for backup file…',
            icon: Icons.folder_open_outlined,
            isFullWidth: true,
            isLoading: _isPicking,
            onPressed: _isPicking ? null : _pickAndRestore,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton.secondary(
            label: 'Cancel',
            isFullWidth: true,
            onPressed: _isPicking ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
