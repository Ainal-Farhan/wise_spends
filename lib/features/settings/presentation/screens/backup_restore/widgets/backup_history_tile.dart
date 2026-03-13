import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/services/backup/backup_restore_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// A single row in the backup history list showing file metadata and actions.
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
    final isJson = backup.format == 'JSON';
    final color = isJson ? AppColors.primary : AppColors.tertiary;
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(backup.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _FormatBadge(format: backup.format, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FileInfo(
                fileName: backup.fileName,
                dateStr: dateStr,
                formattedSize: backup.formattedSize,
              ),
            ),
            _TileActions(
              onRestore: onRestore,
              onShare: onShare,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatBadge extends StatelessWidget {
  final String format;
  final Color color;

  const _FormatBadge({required this.format, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Center(
        child: Text(
          format,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _FileInfo extends StatelessWidget {
  final String fileName;
  final String dateStr;
  final String formattedSize;

  const _FileInfo({
    required this.fileName,
    required this.dateStr,
    required this.formattedSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fileName,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$dateStr  •  $formattedSize',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

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
