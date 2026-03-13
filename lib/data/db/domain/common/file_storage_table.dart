import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/common/file_storage_enum.dart';

// ─── Table ────────────────────────────────────────────────────────────────────

@DataClassName("${DomainTableConstant.commonTablePrefix}FileStorageTable")
class FileStorageTable extends BaseEntityTable {
  /// Original filename from user
  TextColumn get originalName => text()();

  /// Stored filename (UUID-based, unique)
  TextColumn get storedName => text()();

  /// Absolute local path on device
  TextColumn get localPath => text()();

  /// File extension without leading dot (e.g. jpg, png, pdf).
  /// Named [fileExtension] to avoid conflict with Dart's built-in
  /// `extension` keyword which breaks Drift's code generator.
  TextColumn get fileExtension => text()();

  /// MIME type (e.g. image/jpeg)
  TextColumn get mimeType => text()();

  /// File size in bytes
  IntColumn get sizeBytes => integer()();

  /// Category of the file — stored as [FileCategory].name string
  TextColumn get category =>
      textEnum<FileCategory>().withDefault(Constant(FileCategory.other.name))();

  /// Associated entity id (e.g. userId, transactionId)
  TextColumn get entityId => text().nullable()();

  /// Associated entity type (e.g. 'user', 'transaction')
  TextColumn get entityType => text().nullable()();

  /// Optional description / caption
  TextColumn get description => text().nullable()();

  /// MD5 checksum of the file contents for integrity verification
  TextColumn get checksum => text().nullable()();

  /// Storage status — stored as [FileStorageStatus].name string
  TextColumn get status => textEnum<FileStorageStatus>().withDefault(
    Constant(FileStorageStatus.active.name),
  )();

  /// Whether this file has been backed up
  BoolColumn get isBackedUp => boolean().withDefault(const Constant(false))();

  /// Last backup datetime
  DateTimeColumn get lastBackupAt => dateTime().nullable()();

  /// Relative path within backup archive
  TextColumn get backupPath => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {storedName},
  ];

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'originalName': originalName.name,
      'storedName': storedName.name,
      'localPath': localPath.name,
      'fileExtension': fileExtension.name,
      'mimeType': mimeType.name,
      'sizeBytes': sizeBytes.name,
      'category': category.name,
      'entityId': entityId.name,
      'entityType': entityType.name,
      'description': description.name,
      'checksum': checksum.name,
      'status': status.name,
      'isBackedUp': isBackedUp.name,
      'lastBackupAt': lastBackupAt.name,
      'backupPath': backupPath.name,
    };
  }
}
