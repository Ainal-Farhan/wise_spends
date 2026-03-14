import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/settings/data/services/backup_service.dart';
import 'package:wise_spends/features/settings/presentation/bloc/backup_restore_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/widgets/data_management_tab.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

import 'widgets/backup_operation_loading.dart';
import 'widgets/backup_tab.dart';
import 'widgets/history_tab.dart';

/// Entry point for the Backup & Restore feature.
///
/// Responsibilities:
///   • Provide [BackupRestoreBloc] to the subtree.
///   • Own the [TabController] and [AppBar].
///   • Listen to BLoC state for snackbar feedback and tab navigation.
///   • Delegate all UI to [BackupTab], [HistoryTab], [DataManagementTab],
///     and [BackupOperationLoading].
class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BackupRestoreBloc(BackupService())..add(const LoadBackupHistory()),
      child: const _BackupRestoreView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BackupRestoreView extends StatefulWidget {
  const _BackupRestoreView();

  @override
  State<_BackupRestoreView> createState() => _BackupRestoreViewState();
}

class _BackupRestoreViewState extends State<_BackupRestoreView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Tab indices — keep in sync with the [TabBar] children list below.
  static const int _kBackupTab = 0;
  static const int _kHistoryTab = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(BackupRestoreKeys.title.tr),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.cloud_upload_outlined),
              text: BackupRestoreKeys.tabBackup.tr,
            ),
            Tab(
              icon: const Icon(Icons.history_rounded),
              text: BackupRestoreKeys.tabHistory.tr,
            ),
            Tab(icon: const Icon(Icons.folder_outlined), text: 'Data'),
          ],
        ),
      ),
      body: BlocConsumer<BackupRestoreBloc, BackupRestoreState>(
        listener: _onStateChange,
        builder: (context, state) {
          if (_isLoading(state)) {
            return BackupOperationLoading(state: state);
          }
          return TabBarView(
            controller: _tabController,
            children: const [BackupTab(), HistoryTab(), DataManagementTab()],
          );
        },
      ),
    );
  }

  // ── State listener ────────────────────────────────────────────────────────

  void _onStateChange(BuildContext context, BackupRestoreState state) {
    if (state is BackupRestoreExportSuccess) {
      final msg = state.shared
          ? BackupRestoreKeys.snackExportSharedSuccess.trWith({
              'format': state.format,
            })
          : BackupRestoreKeys.snackExportSavedSuccess.trWith({
              'format': state.format,
            });
      _snack(
        context,
        message: msg,
        icon: Icons.check_circle_rounded,
        color: Theme.of(context).colorScheme.primary,
      );

      if (!state.shared) {
        // Reload history then switch to History tab.
        context.read<BackupRestoreBloc>().add(const LoadBackupHistory());
        _tabController.animateTo(_kHistoryTab);
      }
    } else if (state is BackupRestoreExportFullSuccess) {
      final msg = state.shared
          ? 'Full backup shared successfully (includes files)'
          : 'Full backup saved successfully (includes files)';
      _snack(
        context,
        message: msg,
        icon: Icons.check_circle_rounded,
        color: Theme.of(context).colorScheme.primary,
      );

      if (!state.shared) {
        context.read<BackupRestoreBloc>().add(const LoadBackupHistory());
        _tabController.animateTo(_kHistoryTab);
      }
    } else if (state is BackupRestoreImportSuccess) {
      _snack(
        context,
        message: BackupRestoreKeys.snackImportSuccess.tr,
        icon: Icons.check_circle_rounded,
        color: Theme.of(context).colorScheme.primary,
      );
    } else if (state is BackupShareSuccess) {
      _snack(
        context,
        message: BackupRestoreKeys.snackShareSuccess.tr,
        icon: Icons.ios_share_rounded,
        color: Theme.of(context).colorScheme.primary,
      );
    } else if (state is BackupDeleteSuccess) {
      _snack(
        context,
        message: BackupRestoreKeys.snackDeleteSuccess.tr,
        icon: Icons.delete_outline_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    } else if (state is ResetDataSuccess) {
      _snack(
        context,
        message: 'All data has been reset successfully',
        icon: Icons.check_circle_rounded,
        color: Theme.of(context).colorScheme.primary,
      );
      // Return to Backup tab after a full reset for a fresh start UX.
      _tabController.animateTo(_kBackupTab);
      // Reload history (will be empty) and files.
      context.read<BackupRestoreBloc>().add(const LoadBackupHistory());
    } else if (state is FileDeleted) {
      _snack(
        context,
        message: 'File deleted successfully',
        icon: Icons.delete_outline_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
      // Reload file list so the Data Management tab refreshes automatically.
      context.read<BackupRestoreBloc>().add(const LoadAllFiles());
    } else if (_isError(state)) {
      _snack(
        context,
        message: _errorMessage(state),
        icon: Icons.error_outline_rounded,
        color: Theme.of(context).colorScheme.error,
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isLoading(BackupRestoreState state) =>
      state is BackupRestoreExporting ||
      state is BackupRestoreExportingFull ||
      state is BackupRestoreImporting ||
      state is BackupSharingFile ||
      state is BackupDeletingFile ||
      state is ResettingData ||
      state is LoadingFiles ||
      state is FileDeleting;

  bool _isError(BackupRestoreState state) =>
      state is BackupRestoreExportError ||
      state is BackupRestoreExportFullError ||
      state is BackupRestoreImportError ||
      state is BackupShareError ||
      state is BackupDeleteError ||
      state is BackupHistoryError ||
      state is ResetDataError ||
      state is FilesError ||
      state is FileDeleteError;

  String _errorMessage(BackupRestoreState state) => switch (state) {
    BackupRestoreExportError s => s.message,
    BackupRestoreExportFullError s => s.message,
    BackupRestoreImportError s => s.message,
    BackupShareError s => s.message,
    BackupDeleteError s => s.message,
    BackupHistoryError s => s.message,
    ResetDataError s => s.message,
    FilesError s => s.message,
    FileDeleteError s => s.message,
    _ => '',
  };

  void _snack(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
