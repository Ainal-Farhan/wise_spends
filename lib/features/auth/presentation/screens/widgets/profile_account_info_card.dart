import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/services/document_service.dart';
import 'package:wise_spends/domain/models/user_profile.dart';
import 'package:wise_spends/features/auth/presentation/screens/widgets/profile_form_fields.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Displays read-only account metadata (member since, last updated, user ID)
/// plus a live storage stats summary.
class ProfileAccountInfoCard extends StatefulWidget {
  const ProfileAccountInfoCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<ProfileAccountInfoCard> createState() => _ProfileAccountInfoCardState();
}

class _ProfileAccountInfoCardState extends State<ProfileAccountInfoCard> {
  StorageStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DocumentService.instance.getStorageStats();
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: 'profile.account_info'.tr,
          subtitle: 'profile.account_info_desc'.tr,
          icon: Icons.info_outline,
        ),
        const SizedBox(height: AppSpacing.lg),

        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _InfoRow(
                label: 'profile.member_since'.tr,
                value: _formatDate(widget.profile.dateCreated),
                icon: Icons.calendar_today_outlined,
              ),
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                label: 'profile.last_updated'.tr,
                value: _formatDate(widget.profile.dateUpdated),
                icon: Icons.update_outlined,
              ),
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                label: 'profile.user_id'.tr,
                value: widget.profile.id,
                icon: Icons.badge_outlined,
                isMonospace: true,
              ),
              if (_stats != null) ...[
                const Divider(height: AppSpacing.xl),
                _StorageSummaryRow(stats: _stats!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isMonospace = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.sm,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StorageSummaryRow extends StatelessWidget {
  const _StorageSummaryRow({required this.stats});

  final StorageStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.folder_outlined,
          size: AppIconSize.sm,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage used',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    stats.formattedTotal,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (stats.pendingBackupCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${stats.pendingBackupCount} unbackedup',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
