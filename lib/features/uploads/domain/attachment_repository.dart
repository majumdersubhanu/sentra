import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../shared/domain/attachment.dart';

abstract interface class AttachmentRepository {
  /// Upload a file immediately (used by sync engine after offline queue drains).
  Future<Either<Failure, String>> uploadAttachment({
    required XFile file,
    required String entityType,
    required String entityId,
  });

  /// Queue a file upload for offline-first operation.
  Future<Either<Failure, void>> queueAttachment({
    required String id,
    required String entityId,
    required String entityType,
    required String filePath,
    required String fileName,
    required String contentType,
    required int byteSize,
  });

  /// Fetch all attachments for a given entity (merges local pending + remote).
  Future<Either<Failure, List<Attachment>>> getAttachmentsForEntity(
    String entityId,
  );

  /// Legacy: list Supabase Storage paths for an entity.
  Future<Either<Failure, List<String>>> getAttachments(
    String entityType,
    String entityId,
  );
}
