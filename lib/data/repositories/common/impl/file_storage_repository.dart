import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/common/file_storage_enum.dart';
import 'package:wise_spends/data/repositories/common/i_file_storage_repository.dart';
import 'package:wise_spends/domain/models/stored_file.dart';

/// File Storage Repository Implementation
///
/// Manages physical file I/O on the device and keeps the SQLite (Drift) record
/// in sync.  All user files are written to:
///   {app_documents}/wise_spends_files/{category}/{storedName}
///
/// Backups are written to:
///   {app_documents}/wise_spends_backups/backup_{timestamp}.zip
class FileStorageRepository extends IFileStorageRepository {
  FileStorageRepository() : super(AppDatabase());

  // ─── Directories ──────────────────────────────────────────────────────────

  static const _filesDirName = 'wise_spends_files';
  static const _backupsDirName = 'wise_spends_backups';

  Future<Directory> get _filesDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _filesDirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> get _backupsDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _backupsDirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _categoryDir(FileCategory category) async {
    final base = await _filesDir;
    final dir = Directory(p.join(base.path, category.name));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // ─── ICrudRepository ──────────────────────────────────────────────────────

  @override
  String getTypeName() => 'FileStorageTable';

  @override
  CmmnFileStorageTable fromJson(Map<String, dynamic> json) =>
      CmmnFileStorageTable.fromJson(json);

  // ─── Store file ───────────────────────────────────────────────────────────

  @override
  Future<StoredFile?> storeFile({
    required File sourceFile,
    required FileCategory category,
    String? entityId,
    String? entityType,
    String? description,
  }) async {
    try {
      final originalName = p.basename(sourceFile.path);
      final ext = p.extension(sourceFile.path).replaceFirst('.', '');
      final mime =
          lookupMimeType(sourceFile.path) ?? 'application/octet-stream';
      final storedName = '${UuidGenerator().v4()}.$ext';
      final destDir = await _categoryDir(category);
      final destPath = p.join(destDir.path, storedName);

      // Copy file to managed location
      final copiedFile = await sourceFile.copy(destPath);

      // Compute MD5 checksum
      final bytes = await copiedFile.readAsBytes();
      final checksum = md5.convert(bytes).toString();
      final sizeBytes = await copiedFile.length();
      final now = DateTime.now();

      final companion = FileStorageTableCompanion(
        originalName: Value(originalName),
        storedName: Value(storedName),
        localPath: Value(destPath),
        fileExtension: Value(ext),
        mimeType: Value(mime),
        sizeBytes: Value(sizeBytes),
        category: Value(category),
        entityId: Value(entityId),
        entityType: Value(entityType),
        description: Value(description),
        checksum: Value(checksum),
        status: const Value(FileStorageStatus.active),
        isBackedUp: const Value(false),
        dateUpdated: Value(now),
        createdBy: const Value('user'),
        lastModifiedBy: const Value('user'),
      );

      await db.into(db.fileStorageTable).insert(companion);

      final inserted =
          await (db.select(db.fileStorageTable)
                ..where((t) => t.storedName.equals(storedName))
                ..limit(1))
              .getSingleOrNull();

      return inserted != null ? StoredFile.fromCmmnFileStorage(inserted) : null;
    } catch (e) {
      return null;
    }
  }

  // ─── Get file ─────────────────────────────────────────────────────────────

  @override
  Future<StoredFile?> getFile(String id) async {
    final row =
        await (db.select(db.fileStorageTable)
              ..where((t) => t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    return row != null ? StoredFile.fromCmmnFileStorage(row) : null;
  }

  // ─── Files for entity ─────────────────────────────────────────────────────

  @override
  Future<List<StoredFile>> getFilesForEntity({
    required String entityId,
    required String entityType,
  }) async {
    final rows =
        await (db.select(db.fileStorageTable)
              ..where(
                (t) =>
                    t.entityId.equals(entityId) &
                    t.entityType.equals(entityType) &
                    t.status.equals('active'),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
            .get();
    return rows.map(StoredFile.fromCmmnFileStorage).toList();
  }

  @override
  Stream<List<StoredFile>> watchFilesForEntity({
    required String entityId,
    required String entityType,
  }) {
    return (db.select(db.fileStorageTable)
          ..where(
            (t) =>
                t.entityId.equals(entityId) &
                t.entityType.equals(entityType) &
                t.status.equals('active'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .watch()
        .map((rows) => rows.map(StoredFile.fromCmmnFileStorage).toList());
  }

  // ─── Latest profile image ─────────────────────────────────────────────────

  @override
  Future<StoredFile?> getLatestProfileImage(String userId) async {
    final row =
        await (db.select(db.fileStorageTable)
              ..where(
                (t) =>
                    t.entityId.equals(userId) &
                    t.category.equals(FileCategory.profileImage.name) &
                    t.status.equals('active'),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)])
              ..limit(1))
            .getSingleOrNull();
    return row != null ? StoredFile.fromCmmnFileStorage(row) : null;
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  @override
  Future<bool> deleteFile(String id) async {
    try {
      final row = await getFile(id);
      if (row == null) return false;

      // Soft-delete in DB
      await (db.update(
        db.fileStorageTable,
      )..where((t) => t.id.equals(id))).write(
        FileStorageTableCompanion(
          status: const Value(FileStorageStatus.deleted),
          dateUpdated: Value(DateTime.now()),
          lastModifiedBy: const Value('user'),
        ),
      );

      // Remove physical file
      final file = File(row.localPath);
      if (await file.exists()) await file.delete();

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> purgeDeletedFiles() async {
    final deleted = await (db.select(
      db.fileStorageTable,
    )..where((t) => t.status.equals('deleted'))).get();

    int count = 0;
    for (final row in deleted) {
      final file = File(row.localPath);
      if (await file.exists()) await file.delete();
      await (db.delete(
        db.fileStorageTable,
      )..where((t) => t.id.equals(row.id))).go();
      count++;
    }
    return count;
  }

  // ─── Backup ───────────────────────────────────────────────────────────────

  @override
  Future<String?> createBackup({String? destinationPath}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final backupsDir = await _backupsDir;
      final archivePath =
          destinationPath ?? p.join(backupsDir.path, 'backup_$timestamp.zip');

      final encoder = ZipFileEncoder();
      encoder.create(archivePath);

      // 1. Add all active physical files
      final activeFiles = await (db.select(
        db.fileStorageTable,
      )..where((t) => t.status.equals('active'))).get();

      for (final row in activeFiles) {
        final file = File(row.localPath);
        if (await file.exists()) {
          encoder.addFile(file, p.join(row.category.name, row.storedName));
        }
      }

      // 2. Export DB manifest as JSON
      final manifest = activeFiles.map((r) => r.toJson()).toList();
      final manifestJson = jsonEncode({
        'files': manifest,
        'exportedAt': timestamp,
      });
      final tmpDir = await getTemporaryDirectory();
      final manifestFile = File(p.join(tmpDir.path, 'manifest.json'));
      await manifestFile.writeAsString(manifestJson);
      encoder.addFile(manifestFile, 'manifest.json');

      encoder.close();

      // Mark all as backed up
      for (final row in activeFiles) {
        await markAsBackedUp(row.id, backupPath: archivePath);
      }
      await manifestFile.delete();

      return archivePath;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> restoreFromBackup(String archivePath) async {
    try {
      final archive = ZipDecoder().decodeBytes(
        await File(archivePath).readAsBytes(),
      );

      final filesDir = await _filesDir;

      // Read manifest
      final manifestEntry = archive.files.firstWhere(
        (f) => f.name == 'manifest.json',
      );
      final manifest =
          jsonDecode(utf8.decode(manifestEntry.content as List<int>))
              as Map<String, dynamic>;

      final files = (manifest['files'] as List).cast<Map<String, dynamic>>();

      for (final fileEntry in archive.files) {
        if (fileEntry.name == 'manifest.json') continue;
        if (!fileEntry.isFile) continue;

        final destFile = File(p.join(filesDir.path, fileEntry.name));
        await destFile.parent.create(recursive: true);
        await destFile.writeAsBytes(fileEntry.content as List<int>);
      }

      // Re-insert DB records
      for (final json in files) {
        final existing = await (db.select(
          db.fileStorageTable,
        )..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
        if (existing == null) {
          await db
              .into(db.fileStorageTable)
              .insert(CmmnFileStorageTable.fromJson(json));
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> markAsBackedUp(String id, {String? backupPath}) async {
    try {
      await (db.update(
        db.fileStorageTable,
      )..where((t) => t.id.equals(id))).write(
        FileStorageTableCompanion(
          isBackedUp: const Value(true),
          lastBackupAt: Value(DateTime.now()),
          backupPath: Value(backupPath),
          dateUpdated: Value(DateTime.now()),
          lastModifiedBy: const Value('system'),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<StoredFile>> getPendingBackupFiles() async {
    final rows =
        await (db.select(db.fileStorageTable)..where(
              (t) => t.isBackedUp.equals(false) & t.status.equals('active'),
            ))
            .get();
    return rows.map(StoredFile.fromCmmnFileStorage).toList();
  }

  @override
  Future<int> getTotalStorageUsed() async {
    final rows = await (db.select(
      db.fileStorageTable,
    )..where((t) => t.status.equals('active'))).get();
    return rows.fold<int>(0, (sum, r) => sum + r.sizeBytes);
  }

  @override
  Future<List<StoredFile>> getAllActiveFiles() async {
    final rows = await (db.select(
      db.fileStorageTable,
    )..where((t) => t.status.equals('active'))).get();
    return rows.map(StoredFile.fromCmmnFileStorage).toList();
  }
}
