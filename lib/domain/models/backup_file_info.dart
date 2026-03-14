import 'package:equatable/equatable.dart';

/// Metadata for a single backup file stored in internal storage
class BackupFileInfo extends Equatable {
  final String filePath;
  final String fileName;
  final String format; // 'JSON' | 'SQLite'
  final int sizeBytes;
  final DateTime createdAt;

  const BackupFileInfo({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.sizeBytes,
    required this.createdAt,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [filePath, fileName, format, sizeBytes, createdAt];
}
