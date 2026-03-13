import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/services/backup/backup_service.dart';
import 'package:wise_spends/core/services/backup/backup_restore_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
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
///   • Delegate all UI to [BackupTab], [HistoryTab], and [BackupOperationLoading].
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            children: [
              BackupTab(state: state),
              HistoryTab(state: state),
            ],
          );
        },
      ),
    );
  }

  // ── State listener ───────────────────────────────────────────────────────────

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
        color: AppColors.success,
      );

      // Navigate to History tab after a silent save so the user sees the new file
      if (!state.shared) {
        context.read<BackupRestoreBloc>().add(const LoadBackupHistory());
        _tabController.animateTo(1);
      }
    } else if (state is BackupRestoreImportSuccess) {
      _snack(
        context,
        message: BackupRestoreKeys.snackImportSuccess.tr,
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
      );
    } else if (state is BackupShareSuccess) {
      _snack(
        context,
        message: BackupRestoreKeys.snackShareSuccess.tr,
        icon: Icons.ios_share_rounded,
        color: AppColors.success,
      );
    } else if (state is BackupDeleteSuccess) {
      _snack(
        context,
        message: BackupRestoreKeys.snackDeleteSuccess.tr,
        icon: Icons.delete_outline_rounded,
        color: AppColors.textSecondary,
      );
    } else if (_isError(state)) {
      _snack(
        context,
        message: _errorMessage(state),
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  bool _isLoading(BackupRestoreState state) =>
      state is BackupRestoreExporting ||
      state is BackupRestoreImporting ||
      state is BackupSharingFile ||
      state is BackupDeletingFile;

  bool _isError(BackupRestoreState state) =>
      state is BackupRestoreExportError ||
      state is BackupRestoreImportError ||
      state is BackupShareError ||
      state is BackupDeleteError ||
      state is BackupHistoryError;

  String _errorMessage(BackupRestoreState state) => switch (state) {
    BackupRestoreExportError s => s.message,
    BackupRestoreImportError s => s.message,
    BackupShareError s => s.message,
    BackupDeleteError s => s.message,
    BackupHistoryError s => s.message,
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
