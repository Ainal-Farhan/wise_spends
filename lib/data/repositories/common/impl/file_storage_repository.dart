import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
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
/// ── ZIP backup layout ────────────────────────────────────────────────────────
///
///   backup_YYYYMMDD_HHmmss_full.zip
///   ├── manifest.json        ← file-storage DB records (for re-import)
///   ├── data.json            ← full database export (all tables)
///   ├── data.sqlite          ← SQLite VACUUM copy of the live database
///   └── files/
///       ├── profileImage/
///       │   └── {storedName}
///       ├── receipt/
///       │   └── {storedName}
///       └── …
///
/// Having both `data.json` and `data.sqlite` inside the ZIP means either
/// restore strategy works from a single archive.
class FileStorageRepository extends IFileStorageRepository {
  FileStorageRepository() : super(AppDatabase());

  // ─── Directories ──────────────────────────────────────────────────────────

  static const _filesDirName = 'wise_spends_files';

  Future<Directory> get _filesDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _filesDirName));
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

      final copiedFile = await sourceFile.copy(destPath);
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

      await (db.update(
        db.fileStorageTable,
      )..where((t) => t.id.equals(id))).write(
        FileStorageTableCompanion(
          status: const Value(FileStorageStatus.deleted),
          dateUpdated: Value(DateTime.now()),
          lastModifiedBy: const Value('user'),
        ),
      );

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

  /// Creates a full backup ZIP at [destinationPath].
  ///
  /// ZIP contents:
  ///   manifest.json  – file-storage DB rows (used by [restoreFromBackup])
  ///   data.json      – full database export via [AppDatabase.exportInto]
  ///   data.sqlite    – SQLite VACUUM copy via [AppDatabase.exportInto]
  ///   files/{cat}/{storedName} – every active physical file
  ///
  /// Returns the path of the created ZIP, or `null` on failure.
  @override
  Future<String?> createBackup({String? destinationPath}) async {
    final tmpDir = await getTemporaryDirectory();
    String? jsonExportPath;
    String? sqliteExportPath;

    try {
      // ── 1. Resolve archive destination ────────────────────────────────────
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final archivePath =
          destinationPath ?? p.join(tmpDir.path, 'backup_$timestamp.zip');

      // ── 2. Export DB — fully await so bytes are flushed before we read ─────
      jsonExportPath = await db.exportInto('.json');
      sqliteExportPath = await db.exportInto('.sqlite');

      // ── 3. Collect active file-storage records ────────────────────────────
      final activeRows = await (db.select(
        db.fileStorageTable,
      )..where((t) => t.status.equals('active'))).get();

      // ── 4. Build manifest JSON bytes ──────────────────────────────────────
      final manifestBytes = utf8.encode(
        jsonEncode({
          'version': 2,
          'exportedAt': timestamp,
          'files': activeRows.map((r) => r.toJson()).toList(),
        }),
      );

      // ── 5. Build Archive in memory with explicit async reads ───────────────
      //
      // IMPORTANT: every readAsBytes() call is individually awaited so the
      // Dart event loop has a chance to flush pending I/O before we compress.
      final archive = Archive();

      void addBytes(String entryName, List<int> bytes) {
        archive.addFile(ArchiveFile(entryName, bytes.length, bytes));
      }

      // Database exports
      addBytes('data.json', await File(jsonExportPath).readAsBytes());
      addBytes('data.sqlite', await File(sqliteExportPath).readAsBytes());

      // File-storage manifest
      addBytes('manifest.json', manifestBytes);

      // Physical uploaded files
      for (final row in activeRows) {
        final file = File(row.localPath);
        if (!await file.exists()) continue;

        // Use forward slashes inside the ZIP regardless of host OS.
        final entryName = 'files/${row.category.name}/${row.storedName}';
        addBytes(entryName, await file.readAsBytes());
      }

      // ── 6. Encode and write the ZIP to disk ───────────────────────────────
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes.isEmpty) {
        throw Exception('ZipEncoder produced empty output');
      }

      final archiveFile = File(archivePath);
      await archiveFile.parent.create(recursive: true);
      await archiveFile.writeAsBytes(zipBytes, flush: true);

      // ── 7. Mark DB records as backed up ───────────────────────────────────
      for (final row in activeRows) {
        await markAsBackedUp(row.id, backupPath: archivePath);
      }

      return archivePath;
    } catch (e) {
      return null;
    } finally {
      // ── 8. Clean up temp DB export files ──────────────────────────────────
      _tryDelete(jsonExportPath);
      _tryDelete(sqliteExportPath);
    }
  }

  // ─── Restore ──────────────────────────────────────────────────────────────

  /// Restores from a full-backup ZIP.
  ///
  /// Strategy:
  ///   1. Extract `data.json` and restore all DB tables from it.
  ///   2. Extract all `files/*` entries back to the managed files directory.
  ///   3. Re-insert file-storage DB records from `manifest.json` (skip
  ///      records that already exist to stay idempotent).
  ///
  /// Falls back to `data.sqlite` if `data.json` is missing (v1 archives).
  @override
  Future<bool> restoreFromBackup(String archivePath) async {
    final tmpDir = await getTemporaryDirectory();

    try {
      final archiveBytes = await File(archivePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(archiveBytes);

      final filesDir = await _filesDir;

      // ── 1. Restore database ────────────────────────────────────────────────
      final jsonEntry = _findEntry(archive, 'data.json');
      final sqliteEntry = _findEntry(archive, 'data.sqlite');

      if (jsonEntry != null) {
        // Write data.json to a temp file then hand off to AppDatabase.
        final tmpJson = File(p.join(tmpDir.path, 'restore_data.json'));
        await tmpJson.writeAsBytes(jsonEntry.content as List<int>);
        await db.restoreFromPath(tmpJson.path, '.json');
        _tryDelete(tmpJson.path);
      } else if (sqliteEntry != null) {
        // Fallback: raw SQLite file swap (v1 archives).
        final tmpSqlite = File(p.join(tmpDir.path, 'restore_data.sqlite'));
        await tmpSqlite.writeAsBytes(sqliteEntry.content as List<int>);
        await db.restoreFromPath(tmpSqlite.path, '.sqlite');
        _tryDelete(tmpSqlite.path);
      }
      // If neither entry exists the ZIP is a legacy archive without a DB
      // export — we still restore the files and manifest below.

      // ── 2. Extract physical files ──────────────────────────────────────────
      for (final entry in archive.files) {
        if (!entry.isFile) continue;
        if (entry.name == 'manifest.json') continue;
        if (entry.name == 'data.json') continue;
        if (entry.name == 'data.sqlite') continue;

        // Entry path inside ZIP:  files/<category>/<storedName>
        if (!entry.name.startsWith('files/')) continue;

        // Strip the leading "files/" prefix to get <category>/<storedName>
        final relativePath = entry.name.substring('files/'.length);
        final destFile = File(p.join(filesDir.path, relativePath));
        await destFile.parent.create(recursive: true);
        await destFile.writeAsBytes(entry.content as List<int>);
      }

      // ── 3. Re-insert file-storage records from manifest ────────────────────
      final manifestEntry = _findEntry(archive, 'manifest.json');
      if (manifestEntry != null) {
        final raw =
            jsonDecode(utf8.decode(manifestEntry.content as List<int>))
                as Map<String, dynamic>;

        // Support both v1 (list at root) and v2 ({ files: [...] }) manifests.
        final fileList = raw.containsKey('files')
            ? (raw['files'] as List).cast<Map<String, dynamic>>()
            : (raw as List).cast<Map<String, dynamic>>();

        for (final json in fileList) {
          final existing = await (db.select(
            db.fileStorageTable,
          )..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
          if (existing == null) {
            await db
                .into(db.fileStorageTable)
                .insert(CmmnFileStorageTable.fromJson(json));
          }
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── markAsBackedUp / getPendingBackupFiles ───────────────────────────────

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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Finds the first archive entry whose name matches [name] (case-insensitive).
  ArchiveFile? _findEntry(Archive archive, String name) {
    try {
      return archive.files.firstWhere(
        (f) => f.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void _tryDelete(String? path) {
    if (path == null) return;
    File(path).exists().then((exists) {
      if (exists) File(path).delete().catchError((_) => File(path));
    });
  }
}
