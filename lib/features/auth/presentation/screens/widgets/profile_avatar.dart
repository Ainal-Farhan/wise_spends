import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wise_spends/domain/models/stored_file.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Displays the user's avatar with an optional camera-badge overlay.
///
/// If [storedImageFile] is provided and its local path exists on disk, the
/// image is rendered from that file.  Otherwise the user's initial is shown.
///
/// Tapping the camera badge (or the "Change / Add photo" chip) calls
/// [onPickImage].
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.storedImageFile,
    this.isUploading = false,
    required this.onPickImage,
    this.size = 120,
  });

  final UserProfile profile;
  final StoredFile? storedImageFile;
  final bool isUploading;
  final VoidCallback onPickImage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _AvatarCircle(
            profile: profile,
            storedImageFile: storedImageFile,
            isUploading: isUploading,
            onPickImage: onPickImage,
            size: size,
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileNameLabel(profile: profile),
          const SizedBox(height: AppSpacing.xs),
          _ChangePhotoChip(
            hasImage: storedImageFile != null,
            onTap: onPickImage,
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.profile,
    required this.storedImageFile,
    required this.isUploading,
    required this.onPickImage,
    required this.size,
  });

  final UserProfile profile;
  final StoredFile? storedImageFile;
  final bool isUploading;
  final VoidCallback onPickImage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCircle(colorScheme),
        Positioned(
          bottom: 0,
          right: 0,
          child: _CameraBadge(isUploading: isUploading, onTap: onPickImage),
        ),
      ],
    );
  }

  Widget _buildCircle(ColorScheme colorScheme) {
    final borderColor = storedImageFile != null
        ? colorScheme.primary
        : colorScheme.outline;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        color: colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _AvatarContent(
        profile: profile,
        storedImageFile: storedImageFile,
        size: size,
      ),
    );
  }
}

class _AvatarContent extends StatelessWidget {
  const _AvatarContent({
    required this.profile,
    required this.storedImageFile,
    required this.size,
  });

  final UserProfile profile;
  final StoredFile? storedImageFile;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (storedImageFile != null) {
      final file = File(storedImageFile!.localPath);
      return ClipOval(
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _InitialText(profile: profile),
        ),
      );
    }
    return ClipOval(child: _InitialText(profile: profile));
  }
}

class _InitialText extends StatelessWidget {
  const _InitialText({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _CameraBadge extends StatelessWidget {
  const _CameraBadge({required this.isUploading, required this.onTap});

  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isUploading
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ProfileNameLabel extends StatelessWidget {
  const _ProfileNameLabel({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Text(
      profile.name,
      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _ChangePhotoChip extends StatelessWidget {
  const _ChangePhotoChip({required this.hasImage, required this.onTap});

  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              hasImage ? 'Change photo' : 'Add photo',
              style: AppTextStyles.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
