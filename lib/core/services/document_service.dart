import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wise_spends/data/repositories/common/impl/file_storage_repository.dart';
import 'package:wise_spends/domain/models/stored_file.dart';
import 'package:wise_spends/data/db/domain/common/file_storage_enum.dart';

/// Result returned from every [DocumentService] operation.
class DocumentResult<T> {
  final T? data;
  final String? error;

  const DocumentResult.success(this.data) : error = null;
  const DocumentResult.failure(this.error) : data = null;

  bool get isSuccess => error == null;
}

/// High-level service for managing user documents and files.
///
/// This is the only class the presentation layer should touch for file I/O.
/// It wraps [FileStorageRepository] and provides convenience helpers like
/// picking images, sharing archives, and computing storage summaries.
class DocumentService {
  DocumentService._();

  static final DocumentService instance = DocumentService._();

  final _repo = FileStorageRepository();
  final _picker = ImagePicker();

  // ─── Profile image ──────────────────────────────────────────────────────

  /// Pick an image from [source] and store it as a profile image for [userId].
  Future<DocumentResult<StoredFile>> pickAndStoreProfileImage({
    required ImageSource source,
    required String userId,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) {
        return const DocumentResult.failure('No image selected');
      }

      // Soft-delete any previous profile image
      final previous = await _repo.getLatestProfileImage(userId);
      if (previous != null) {
        await _repo.deleteFile(previous.id);
      }

      final stored = await _repo.storeFile(
        sourceFile: File(picked.path),
        category: FileCategory.profileImage,
        entityId: userId,
        entityType: 'user',
        description: 'Profile image',
      );

      if (stored == null) {
        return const DocumentResult.failure('Failed to store image');
      }
      return DocumentResult.success(stored);
    } catch (e) {
      return DocumentResult.failure(e.toString());
    }
  }

  /// Fetch the latest profile image for [userId].
  Future<StoredFile?> getProfileImage(String userId) =>
      _repo.getLatestProfileImage(userId);

  /// Convenience: return the [File] object for the profile image if it exists.
  Future<File?> getProfileImageFile(String userId) async {
    final stored = await getProfileImage(userId);
    if (stored == null) return null;
    final file = File(stored.localPath);
    return await file.exists() ? file : null;
  }

  // ─── Generic file store ─────────────────────────────────────────────────

  /// Store any [File] under a given [category].
  Future<DocumentResult<StoredFile>> storeFile({
    required File file,
    required FileCategory category,
    String? entityId,
    String? entityType,
    String? description,
  }) async {
    final stored = await _repo.storeFile(
      sourceFile: file,
      category: category,
      entityId: entityId,
      entityType: entityType,
      description: description,
    );
    return stored != null
        ? DocumentResult.success(stored)
        : const DocumentResult.failure('Failed to store file');
  }

  /// Retrieve a single file by [id].
  Future<StoredFile?> getFile(String id) => _repo.getFile(id);

  /// Retrieve all files for an entity.
  Future<List<StoredFile>> getFilesForEntity({
    required String entityId,
    required String entityType,
  }) => _repo.getFilesForEntity(entityId: entityId, entityType: entityType);

  /// Watch files for an entity (stream).
  Stream<List<StoredFile>> watchFilesForEntity({
    required String entityId,
    required String entityType,
  }) => _repo.watchFilesForEntity(entityId: entityId, entityType: entityType);

  // ─── Delete ─────────────────────────────────────────────────────────────

  Future<DocumentResult<bool>> deleteFile(String id) async {
    final ok = await _repo.deleteFile(id);
    return ok
        ? const DocumentResult.success(true)
        : const DocumentResult.failure('Failed to delete file');
  }

  Future<int> purgeDeletedFiles() => _repo.purgeDeletedFiles();

  // ─── Backup / Restore ───────────────────────────────────────────────────

  /// Create a ZIP backup of all managed files and the DB manifest.
  /// Returns the path to the archive or null on failure.
  Future<DocumentResult<String>> createBackup({String? destinationPath}) async {
    final path = await _repo.createBackup(destinationPath: destinationPath);
    return path != null
        ? DocumentResult.success(path)
        : const DocumentResult.failure('Backup failed');
  }

  /// Restore files from a ZIP [archivePath].
  Future<DocumentResult<bool>> restoreFromBackup(String archivePath) async {
    final ok = await _repo.restoreFromBackup(archivePath);
    return ok
        ? const DocumentResult.success(true)
        : const DocumentResult.failure('Restore failed');
  }

  /// Share a backup archive via the system share sheet.
  Future<void> shareBackup(String archivePath) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(archivePath)],
        subject: 'WiseSpends Backup',
        text:
            'Backup created by WiseSpends – import this file in the app to restore your data.',
      ),
    );
  }

  /// Create a backup then immediately share it.
  Future<DocumentResult<String>> createAndShareBackup() async {
    final result = await createBackup();
    if (!result.isSuccess) return result;
    await shareBackup(result.data!);
    return result;
  }

  // ─── Storage stats ──────────────────────────────────────────────────────

  Future<int> getTotalStorageUsed() => _repo.getTotalStorageUsed();

  Future<List<StoredFile>> getPendingBackupFiles() =>
      _repo.getPendingBackupFiles();

  Future<StorageStats> getStorageStats() async {
    final [totalBytes, pendingFiles] = await Future.wait([
      getTotalStorageUsed().then((v) => v as Object),
      getPendingBackupFiles().then((v) => v as Object),
    ]);

    return StorageStats(
      totalBytes: totalBytes as int,
      pendingBackupCount: (pendingFiles as List<StoredFile>).length,
    );
  }
}

class StorageStats {
  final int totalBytes;
  final int pendingBackupCount;

  const StorageStats({
    required this.totalBytes,
    required this.pendingBackupCount,
  });

  String get formattedTotal {
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
