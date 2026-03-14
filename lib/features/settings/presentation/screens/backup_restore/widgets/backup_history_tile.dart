import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/domain/models/backup_file_info.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// A single row in the backup history list showing file metadata and actions.
///
/// Improvements over original:
///   • Full-ZIP backups show a distinct "ZIP" purple badge.
///   • Each tile has a leading left-border accent that matches the format colour.
///   • Action buttons are icon-only with ink-well ripples for a more native feel.
///   • A "Restore" chip label surfaces the primary action prominently.
class BackupHistoryTile extends StatelessWidget {
  final BackupFileInfo backup;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  const BackupHistoryTile({
    super.key,
    required this.backup,
    required this.onShare,
    required this.onDelete,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, formatLabel) = _resolveFormat(backup.format);
    final dateStr = DateFormat('dd MMM yyyy • HH:mm').format(backup.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(width: 4, color: color),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      // Format badge
                      _FormatBadge(
                        icon: icon,
                        label: formatLabel,
                        color: color,
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // File info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              backup.fileName,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  dateStr,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.data_usage_rounded,
                                  size: 11,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  backup.formattedSize,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      _TileActions(
                        onRestore: onRestore,
                        onShare: onShare,
                        onDelete: onDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns (accentColor, icon, shortLabel) based on the backup format string.
  (Color, IconData, String) _resolveFormat(String format) {
    switch (format.toUpperCase()) {
      case 'JSON':
        return (AppColors.primary, Icons.data_object_rounded, 'JSON');
      case 'SQLITE':
        return (AppColors.tertiary, Icons.storage_rounded, 'SQL');
      case 'ZIP':
        return (const Color(0xFF8B5CF6), Icons.folder_zip_rounded, 'ZIP');
      default:
        return (
          AppColors.textSecondary,
          Icons.insert_drive_file_outlined,
          format,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FormatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FormatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TileActions extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _TileActions({
    required this.onRestore,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
          icon: Icons.restore_rounded,
          tooltip: BackupRestoreKeys.historyActionRestore.tr,
          color: AppColors.tertiary,
          onTap: onRestore,
        ),
        _IconBtn(
          icon: Icons.ios_share_rounded,
          tooltip: BackupRestoreKeys.historyActionShare.tr,
          color: AppColors.primary,
          onTap: onShare,
        ),
        _IconBtn(
          icon: Icons.delete_outline_rounded,
          tooltip: BackupRestoreKeys.historyActionDelete.tr,
          color: AppColors.error,
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
