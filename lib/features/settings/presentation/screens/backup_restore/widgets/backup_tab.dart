import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/settings/presentation/bloc/backup_restore_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

import 'backup_auto_backup_card.dart';
import 'backup_format_card.dart';
import 'backup_hero_card.dart';
import 'backup_restore_card.dart';
import 'backup_section_label.dart';
import 'backup_warning_card.dart';

class BackupTab extends StatefulWidget {
  const BackupTab({super.key});

  @override
  State<BackupTab> createState() => _BackupTabState();
}

class _BackupTabState extends State<BackupTab>
    with AutomaticKeepAliveClientMixin<BackupTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<BackupRestoreBloc, BackupRestoreState>(
      builder: (context, state) {
        // ✅ Read from state.data — works for every state type.
        final autoBackupEnabled = state.data.autoBackupEnabled;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackupHeroCard(),
              const SizedBox(height: AppSpacing.xl),

              BackupSectionLabel(
                icon: Icons.ios_share_rounded,
                title: BackupRestoreKeys.sectionShareTitle.tr,
                subtitle: BackupRestoreKeys.sectionShareSubtitle.tr,
              ),
              const SizedBox(height: AppSpacing.md),
              _ShareFormatRow(onTap: (fmt) => _confirmShare(context, fmt)),

              const SizedBox(height: AppSpacing.xl),

              BackupSectionLabel(
                icon: Icons.save_alt_rounded,
                title: BackupRestoreKeys.sectionSaveTitle.tr,
                subtitle: BackupRestoreKeys.sectionSaveSubtitle.tr,
              ),
              const SizedBox(height: AppSpacing.md),
              _SaveFormatRow(
                onTap: (fmt) => context.read<BackupRestoreBloc>().add(
                  ExportDataToInternalStorage(fmt),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              BackupSectionLabel(
                icon: Icons.restore_rounded,
                title: BackupRestoreKeys.sectionRestoreTitle.tr,
                subtitle: BackupRestoreKeys.sectionRestoreSubtitle.tr,
              ),
              const SizedBox(height: AppSpacing.md),
              BackupRestoreCard(onTap: () => _confirmRestore(context)),

              const SizedBox(height: AppSpacing.xl),

              BackupAutoBackupCard(
                enabled: autoBackupEnabled,
                onToggle: (value) => context.read<BackupRestoreBloc>().add(
                  ToggleAutoBackup(value),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const BackupWarningCard(),
            ],
          ),
        );
      },
    );
  }

  void _confirmShare(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: BackupRestoreKeys.dialogShareTitle.trWith({'format': format}),
          message: BackupRestoreKeys.dialogShareMessage.trWith({
            'format': format,
          }),
          icon: Icons.ios_share_rounded,
          iconColor: Theme.of(context).colorScheme.primary,
          buttons: [
            CustomDialogButton(
              text: BackupRestoreKeys.dialogCancel.tr,
              onPressed: () => Navigator.pop(ctx),
            ),
            CustomDialogButton(
              text: BackupRestoreKeys.dialogShareConfirm.tr,
              isDefault: true,
              onPressed: () {
                Navigator.pop(ctx);
                context.read<BackupRestoreBloc>().add(
                  ExportDataToShare(format),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: BackupRestoreKeys.dialogRestoreTitle.tr,
          message: BackupRestoreKeys.dialogRestoreMessage.tr,
          icon: Icons.warning_amber_rounded,
          iconColor: Theme.of(context).colorScheme.tertiary,
          buttons: [
            CustomDialogButton(
              text: BackupRestoreKeys.dialogCancel.tr,
              onPressed: () => Navigator.pop(ctx),
            ),
            CustomDialogButton(
              text: BackupRestoreKeys.dialogRestoreConfirm.tr,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(ctx);
                context.read<BackupRestoreBloc>().add(
                  const ImportDataFromFile(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareFormatRow extends StatelessWidget {
  final void Function(String format) onTap;
  const _ShareFormatRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BackupFormatCard(
            icon: Icons.data_object_rounded,
            label: BackupRestoreKeys.formatJsonLabel.tr,
            description: BackupRestoreKeys.formatJsonDesc.tr,
            color: Theme.of(context).colorScheme.primary,
            chipLabel: 'Universal',
            onTap: () => onTap('JSON'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: BackupFormatCard(
            icon: Icons.storage_rounded,
            label: BackupRestoreKeys.formatSqliteLabel.tr,
            description: BackupRestoreKeys.formatSqliteDesc.tr,
            color: Theme.of(context).colorScheme.tertiary,
            chipLabel: 'Fast restore',
            onTap: () => onTap('SQLite'),
          ),
        ),
      ],
    );
  }
}

class _SaveFormatRow extends StatelessWidget {
  final void Function(String format) onTap;
  const _SaveFormatRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BackupFormatCard(
            icon: Icons.data_object_rounded,
            label: BackupRestoreKeys.formatJsonLabel.tr,
            description: BackupRestoreKeys.formatJsonDesc.tr,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => onTap('JSON'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: BackupFormatCard(
            icon: Icons.storage_rounded,
            label: BackupRestoreKeys.formatSqliteLabel.tr,
            description: BackupRestoreKeys.formatSqliteDesc.tr,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => onTap('SQLite'),
          ),
        ),
      ],
    );
  }
}
