/// A file attachment linked to a work order, inspection, or asset.
class Attachment {
  final String id;
  final String entityType; // 'work_order', 'inspection', 'asset'
  final String entityId;
  final String fileName;
  final int? fileSizeBytes;
  final String? mimeType;
  final String? uploadedBy; // UUID
  final String? organizationId;
  final DateTime createdAt;

  /// Present when the file only exists locally and hasn't been synced yet.
  final String? filePath;

  /// Present when the file has been uploaded to Supabase Storage.
  final String? fileUrl;

  const Attachment({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.fileName,
    this.fileSizeBytes,
    this.mimeType,
    this.uploadedBy,
    this.organizationId,
    required this.createdAt,
    this.filePath,
    this.fileUrl,
  });

  /// True when the attachment lives only on-device (not yet synced).
  bool get isLocal => filePath != null && fileUrl == null;

  Attachment copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? fileName,
    int? fileSizeBytes,
    String? mimeType,
    String? uploadedBy,
    String? organizationId,
    DateTime? createdAt,
    String? filePath,
    String? fileUrl,
  }) {
    return Attachment(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt ?? this.createdAt,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}
