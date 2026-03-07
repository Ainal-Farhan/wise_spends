import 'package:equatable/equatable.dart';

abstract class BackupRestoreEvent extends Equatable {
  const BackupRestoreEvent();

  @override
  List<Object?> get props => [];
}

class ExportDataToJson extends BackupRestoreEvent {}

class ExportDataToSqlite extends BackupRestoreEvent {}

class ExportDataToDownloads extends BackupRestoreEvent {
  final String format;

  const ExportDataToDownloads(this.format);

  @override
  List<Object?> get props => [format];
}

class ImportDataFromFile extends BackupRestoreEvent {}

class CancelBackupRestore extends BackupRestoreEvent {}
