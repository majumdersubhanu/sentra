import 'package:cross_file/cross_file.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/storage/database.dart';
import '../../../shared/domain/attachment.dart';
import '../domain/attachment_repository.dart';

@LazySingleton(as: AttachmentRepository)
class AttachmentRepositoryImpl implements AttachmentRepository {
  final SupabaseClient _supabase;
  final SentraDatabase _db;
  final ConnectivityService _connectivity;

  AttachmentRepositoryImpl(this._supabase, this._db, this._connectivity);

  @override
  Future<Either<Failure, String>> uploadAttachment({
    required XFile file,
    required String entityType,
    required String entityId,
  }) async {
    try {
      final fileName = p.basename(file.path);
      final storagePath = '$entityType/$entityId/$fileName';
      final fileSize = await file.length();
      final fileBytes = await file.readAsBytes();

      if (_connectivity.isOnline) {
        await _supabase.storage
            .from('attachments')
            .uploadBinary(
              storagePath,
              fileBytes,
              fileOptions: const FileOptions(upsert: true),
            );

        final publicUrl = _supabase.storage
            .from('attachments')
            .getPublicUrl(storagePath);

        await _supabase.from('attachments').insert({
          'entity_type': entityType,
          'entity_id': entityId,
          'file_path': publicUrl,
          'file_name': fileName,
          'file_size_bytes': fileSize,
        });

        await _db
            .into(_db.attachmentEntries)
            .insertOnConflictUpdate(
              AttachmentEntriesCompanion(
                id: Value('att-${DateTime.now().microsecondsSinceEpoch}'),
                entityType: Value(entityType),
                entityId: Value(entityId),
                filePath: Value(publicUrl),
                fileName: Value(fileName),
                fileSizeBytes: Value(fileSize),
                syncStatus: const Value('synced'),
              ),
            );

        return Right(publicUrl);
      } else {
        final localPath = file.path;

        await _db
            .into(_db.attachmentEntries)
            .insertOnConflictUpdate(
              AttachmentEntriesCompanion(
                id: Value('att-${DateTime.now().microsecondsSinceEpoch}'),
                entityType: Value(entityType),
                entityId: Value(entityId),
                filePath: Value(localPath),
                fileName: Value(fileName),
                fileSizeBytes: Value(fileSize),
                syncStatus: const Value('pending'),
              ),
            );

        await _db
            .into(_db.syncQueueEntries)
            .insert(
              SyncQueueEntriesCompanion.insert(
                entityType: 'attachment',
                entityId: entityId,
                mutationType: 'file_upload',
                payload: jsonEncode({
                  'local_path': localPath,
                  'entity_type': entityType,
                  'entity_id': entityId,
                  'file_name': fileName,
                  'file_size_bytes': fileSize,
                }),
              ),
            );

        return Right(localPath);
      }
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> queueAttachment({
    required String id,
    required String entityId,
    required String entityType,
    required String filePath,
    required String fileName,
    required String contentType,
    required int byteSize,
  }) async {
    try {
      await _db
          .into(_db.attachmentEntries)
          .insertOnConflictUpdate(
            AttachmentEntriesCompanion(
              id: Value(id),
              entityType: Value(entityType),
              entityId: Value(entityId),
              filePath: Value(filePath),
              fileName: Value(fileName),
              fileSizeBytes: Value(byteSize),
              syncStatus: const Value('pending'),
            ),
          );

      await _db
          .into(_db.syncQueueEntries)
          .insert(
            SyncQueueEntriesCompanion.insert(
              entityType: 'attachment',
              entityId: entityId,
              mutationType: 'file_upload',
              payload: jsonEncode({
                'attachment_id': id,
                'local_path': filePath,
                'entity_type': entityType,
                'entity_id': entityId,
                'file_name': fileName,
                'file_size_bytes': byteSize,
                'content_type': contentType,
              }),
            ),
          );

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Attachment>>> getAttachmentsForEntity(
    String entityId,
  ) async {
    try {
      // 1. Always read from local cache first (offline-first)
      final localRows = await (_db.select(
        _db.attachmentEntries,
      )..where((t) => t.entityId.equals(entityId))).get();

      final localAttachments = localRows.map((e) {
        final isRemote = e.syncStatus == 'synced';
        return Attachment(
          id: e.id,
          entityType: e.entityType,
          entityId: e.entityId,
          fileName: e.fileName,
          fileSizeBytes: e.fileSizeBytes,
          createdAt: e.createdAt,
          filePath: isRemote ? null : e.filePath,
          fileUrl: isRemote ? e.filePath : null,
        );
      }).toList();

      // 2. If online, also try to refresh from remote for anything we may have missed
      if (_connectivity.isOnline) {
        try {
          final remote = await _supabase
              .from('attachments')
              .select()
              .eq('entity_id', entityId);

          for (final row in (remote as List)) {
            final url = row['file_path'] as String? ?? '';
            if (url.isEmpty) continue;
            final id = row['id'] as String? ?? '';
            // Upsert into local cache
            await _db
                .into(_db.attachmentEntries)
                .insertOnConflictUpdate(
                  AttachmentEntriesCompanion(
                    id: Value(id),
                    entityType: Value(row['entity_type'] as String? ?? ''),
                    entityId: Value(entityId),
                    filePath: Value(url),
                    fileName: Value(row['file_name'] as String? ?? ''),
                    fileSizeBytes: Value(row['file_size_bytes'] as int?),
                    syncStatus: const Value('synced'),
                  ),
                );
          }

          // Re-read from local to return a unified list
          final merged = await (_db.select(
            _db.attachmentEntries,
          )..where((t) => t.entityId.equals(entityId))).get();

          return Right(
            merged.map((e) {
              final isRemote = e.syncStatus == 'synced';
              return Attachment(
                id: e.id,
                entityType: e.entityType,
                entityId: e.entityId,
                fileName: e.fileName,
                fileSizeBytes: e.fileSizeBytes,
                createdAt: e.createdAt,
                filePath: isRemote ? null : e.filePath,
                fileUrl: isRemote ? e.filePath : null,
              );
            }).toList(),
          );
        } catch (_) {
          // Network error: fall through to local result
        }
      }

      return Right(localAttachments);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAttachments(
    String entityType,
    String entityId,
  ) async {
    try {
      if (!_connectivity.isOnline) {
        return Right(await _getLocalAttachmentPaths(entityType, entityId));
      }

      final response = await _supabase
          .from('attachments')
          .select('file_path')
          .eq('entity_type', entityType)
          .eq('entity_id', entityId);

      final paths = (response as List)
          .map((r) => r['file_path'] as String)
          .toList();
      return Right(paths);
    } catch (e) {
      try {
        return Right(await _getLocalAttachmentPaths(entityType, entityId));
      } catch (_) {
        return Left(DatabaseFailure(e.toString()));
      }
    }
  }

  Future<List<String>> _getLocalAttachmentPaths(
    String entityType,
    String entityId,
  ) async {
    final local =
        await (_db.select(_db.attachmentEntries)..where(
              (t) =>
                  t.entityType.equals(entityType) & t.entityId.equals(entityId),
            ))
            .get();
    return local.map((entry) => entry.filePath).toList();
  }
}
