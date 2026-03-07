import 'package:equatable/equatable.dart';

abstract class BackupRestoreState extends Equatable {
  const BackupRestoreState();

  @override
  List<Object?> get props => [];
}

class BackupRestoreInitial extends BackupRestoreState {}

class BackupRestoreLoading extends BackupRestoreState {}

class BackupRestoreExporting extends BackupRestoreState {
  final String format;

  const BackupRestoreExporting(this.format);

  @override
  List<Object?> get props => [format];
}

class BackupRestoreExportSuccess extends BackupRestoreState {
  final String filePath;
  final String format;

  const BackupRestoreExportSuccess(this.filePath, this.format);

  @override
  List<Object?> get props => [filePath, format];
}

class BackupRestoreExportError extends BackupRestoreState {
  final String message;

  const BackupRestoreExportError(this.message);

  @override
  List<Object?> get props => [message];
}

class BackupRestoreImporting extends BackupRestoreState {}

class BackupRestoreImportSuccess extends BackupRestoreState {
  const BackupRestoreImportSuccess();
}

class BackupRestoreImportError extends BackupRestoreState {
  final String message;

  const BackupRestoreImportError(this.message);

  @override
  List<Object?> get props => [message];
}
