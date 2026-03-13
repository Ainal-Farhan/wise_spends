import 'package:wise_spends/data/db/domain/common/file_storage_enum.dart';

/// Domain model representing a managed file stored on device
class StoredFile {
  final String id;
  final String originalName;
  final String storedName;
  final String localPath;
  final String fileExtension;
  final String mimeType;
  final int sizeBytes;
  final FileCategory category;
  final String? entityId;
  final String? entityType;
  final String? description;
  final String? checksum;
  final FileStorageStatus status;
  final bool isBackedUp;
  final DateTime? lastBackupAt;
  final String? backupPath;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String createdBy;
  final String lastModifiedBy;

  const StoredFile({
    required this.id,
    required this.originalName,
    required this.storedName,
    required this.localPath,
    required this.fileExtension,
    required this.mimeType,
    required this.sizeBytes,
    required this.category,
    this.entityId,
    this.entityType,
    this.description,
    this.checksum,
    required this.status,
    required this.isBackedUp,
    this.lastBackupAt,
    this.backupPath,
    required this.dateCreated,
    required this.dateUpdated,
    required this.createdBy,
    required this.lastModifiedBy,
  });

  /// Human-readable file size
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Whether this is an image file
  bool get isImage =>
      mimeType.startsWith('image/') ||
      [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
      ].contains(fileExtension.toLowerCase());

  /// Whether this is a PDF
  bool get isPdf =>
      mimeType == 'application/pdf' || fileExtension.toLowerCase() == 'pdf';

  StoredFile copyWith({
    String? id,
    String? originalName,
    String? storedName,
    String? localPath,
    String? fileExtension,
    String? mimeType,
    int? sizeBytes,
    FileCategory? category,
    String? entityId,
    String? entityType,
    String? description,
    String? checksum,
    FileStorageStatus? status,
    bool? isBackedUp,
    DateTime? lastBackupAt,
    String? backupPath,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? createdBy,
    String? lastModifiedBy,
  }) {
    return StoredFile(
      id: id ?? this.id,
      originalName: originalName ?? this.originalName,
      storedName: storedName ?? this.storedName,
      localPath: localPath ?? this.localPath,
      fileExtension: fileExtension ?? this.fileExtension,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      category: category ?? this.category,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      description: description ?? this.description,
      checksum: checksum ?? this.checksum,
      status: status ?? this.status,
      isBackedUp: isBackedUp ?? this.isBackedUp,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      backupPath: backupPath ?? this.backupPath,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalName': originalName,
      'storedName': storedName,
      'localPath': localPath,
      'fileExtension': fileExtension,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'category': category.name,
      'entityId': entityId,
      'entityType': entityType,
      'description': description,
      'checksum': checksum,
      'status': status.name,
      'isBackedUp': isBackedUp,
      'lastBackupAt': lastBackupAt?.millisecondsSinceEpoch,
      'backupPath': backupPath,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'dateUpdated': dateUpdated.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
    };
  }

  factory StoredFile.fromCmmnFileStorage(dynamic row) {
    return StoredFile(
      id: row.id,
      originalName: row.originalName,
      storedName: row.storedName,
      localPath: row.localPath,
      fileExtension: row.fileExtension,
      mimeType: row.mimeType,
      sizeBytes: row.sizeBytes,
      category: FileCategory.values.firstWhere(
        (e) => e.name == row.category,
        orElse: () => FileCategory.other,
      ),
      entityId: row.entityId,
      entityType: row.entityType,
      description: row.description,
      checksum: row.checksum,
      status: FileStorageStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => FileStorageStatus.active,
      ),
      isBackedUp: row.isBackedUp,
      lastBackupAt: row.lastBackupAt,
      backupPath: row.backupPath,
      dateCreated: row.dateCreated,
      dateUpdated: row.dateUpdated,
      createdBy: row.createdBy,
      lastModifiedBy: row.lastModifiedBy,
    );
  }
}
