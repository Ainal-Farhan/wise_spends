import 'dart:io';

import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/common/file_storage_enum.dart';
import 'package:wise_spends/data/db/domain/common/file_storage_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/domain/models/stored_file.dart';

/// File Storage Repository Interface
abstract class IFileStorageRepository
    extends
        ICrudRepository<
          FileStorageTable,
          $FileStorageTableTable,
          FileStorageTableCompanion,
          CmmnFileStorageTable
        > {
  IFileStorageRepository(AppDatabase db) : super(db, db.fileStorageTable);

  /// Store a new file: copies it to app documents dir, creates DB record.
  /// Returns the [StoredFile] model on success.
  Future<StoredFile?> storeFile({
    required File sourceFile,
    required FileCategory category,
    String? entityId,
    String? entityType,
    String? description,
  });

  /// Retrieve a [StoredFile] record by its id.
  Future<StoredFile?> getFile(String id);

  /// Retrieve all files belonging to a given entity.
  Future<List<StoredFile>> getFilesForEntity({
    required String entityId,
    required String entityType,
  });

  /// Watch all active files for an entity (reactive stream).
  Stream<List<StoredFile>> watchFilesForEntity({
    required String entityId,
    required String entityType,
  });

  /// Retrieve the most recent profile image for a user.
  Future<StoredFile?> getLatestProfileImage(String userId);

  /// Soft-delete a file record (marks status = deleted) and removes physical file.
  Future<bool> deleteFile(String id);

  /// Permanently purge all soft-deleted records and their physical files.
  Future<int> purgeDeletedFiles();

  /// Create a ZIP backup of all active files + DB export JSON.
  /// Returns the path to the created archive.
  Future<String?> createBackup({String? destinationPath});

  /// Restore from a ZIP backup archive.
  Future<bool> restoreFromBackup(String archivePath);

  /// Mark a file record as backed up.
  Future<bool> markAsBackedUp(String id, {String? backupPath});

  /// List all files that have NOT been backed up yet.
  Future<List<StoredFile>> getPendingBackupFiles();

  /// Compute total storage used (bytes) by active files.
  Future<int> getTotalStorageUsed();
}
