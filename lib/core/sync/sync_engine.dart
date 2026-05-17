import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/connectivity_service.dart';
import '../storage/database.dart';
import '../../features/auth/domain/auth_repository.dart';
import 'package:drift/drift.dart' hide Column;

/// Drains the local sync queue when connectivity is available.
/// Uses FIFO ordering with exponential backoff on failures.
class SyncEngine {
  final SentraDatabase _db;
  final ConnectivityService _connectivity;
  final AuthRepository _authRepository;

  Timer? _drainTimer;
  StreamSubscription<bool>? _connectivitySub;
  bool _isSyncing = false;
  int _consecutiveFailures = 0;

  static const _maxRetries = 5;
  static const _baseBackoffMs = 1000; // 1 second

  SyncEngine(this._db, this._connectivity, this._authRepository);

  /// Start listening for connectivity changes and drain the queue.
  void start() {
    // Drain immediately if online
    if (_connectivity.isOnline) {
      _scheduleDrain();
    }

    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) {
        _consecutiveFailures = 0;
        _scheduleDrain();
      } else {
        _drainTimer?.cancel();
      }
    });
  }

  /// Stop the sync engine.
  void stop() {
    _drainTimer?.cancel();
    _connectivitySub?.cancel();
  }

  /// Schedule a drain pass (with optional backoff delay).
  void _scheduleDrain({int delayMs = 0}) {
    _drainTimer?.cancel();
    _drainTimer = Timer(Duration(milliseconds: delayMs), _drainQueue);
  }

  /// Process all pending mutations in FIFO order.
  Future<void> _drainQueue() async {
    if (_isSyncing || !_connectivity.isOnline) return;
    _isSyncing = true;

    try {
      final mutations = await _db.syncQueueDao.getPendingMutations();
      if (mutations.isEmpty) {
        _isSyncing = false;
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '[SyncEngine] Draining ${mutations.length} pending mutations',
        );
      }

      SupabaseClient? client;
      try {
        client = Supabase.instance.client;
      } catch (_) {
        _isSyncing = false;
        return;
      }

      for (final mutation in mutations) {
        if (!_connectivity.isOnline) break;

        try {
          await _db.syncQueueDao.markInProgress(mutation.id);
          await _processMutation(client, mutation);
          await _db.syncQueueDao.markSuccess(mutation.id);

          // Mark the entity as synced in its table
          await _markEntitySynced(mutation.entityType, mutation.entityId);

          _consecutiveFailures = 0;
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '[SyncEngine] Failed to sync ${mutation.entityType}/${mutation.entityId}: $e',
            );
          }

          await _db.syncQueueDao.markFailed(mutation.id, e.toString());
          _consecutiveFailures++;
          final retryCount = mutation.retryCount + 1;

          if (retryCount >= _maxRetries) {
            if (kDebugMode) {
              debugPrint(
                '[SyncEngine] Max retries reached for mutation ${mutation.id}, marking as permanently failed',
              );
            }
            continue; // Skip this mutation, move to the next
          }

          // Keep retryable mutations in pending so the next drain pass can pick them.
          await _db.syncQueueDao.retryById(mutation.id);

          // Exponential backoff: reschedule
          final backoff =
              _baseBackoffMs * (1 << _consecutiveFailures.clamp(0, 6));
          _isSyncing = false;
          _scheduleDrain(delayMs: backoff);
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SyncEngine] Queue drain error: $e');
      }
    }

    _isSyncing = false;

    // Check if more mutations arrived during processing
    final remaining = await _db.syncQueueDao.getPendingMutations();
    if (remaining.isNotEmpty && _connectivity.isOnline) {
      _scheduleDrain(delayMs: 500); // Brief pause before next batch
    }
  }

  /// Execute a single mutation against Supabase.
  Future<void> _processMutation(
    SupabaseClient client,
    SyncQueueEntry mutation,
  ) async {
    final payload = jsonDecode(mutation.payload) as Map<String, dynamic>;

    switch (mutation.mutationType) {
      case 'create':
        await client.from(_tableFor(mutation.entityType)).insert(payload);
        break;
      case 'update':
      case 'upsert':
        final id = payload['id'] as String;
        final tableName = _tableFor(mutation.entityType);

        // Fetch current server state
        final serverResponse = await client
            .from(tableName)
            .select()
            .eq('id', id)
            .maybeSingle();

        if (serverResponse != null) {
          final serverData = serverResponse;
          final serverUpdatedBy = serverData['updated_by'] as String?;

          // Role-aware conflict check
          final currentUser = _authRepository.currentUserProfile;
          if (currentUser != null && currentUser.role.isSupervisorOrAbove) {
            // Check if server was updated by someone with a lower role
            // This is a simplification; in real app we'd fetch the role of serverUpdatedBy
            // For now, if serverUpdatedBy != currentUser.id, we treat as potential conflict
            if (serverUpdatedBy != null && serverUpdatedBy != currentUser.id) {
              // Save conflict for review
              await _db.conflictDao.upsertConflict(
                ConflictEntriesCompanion(
                  id: Value(id),
                  entityType: Value(mutation.entityType),
                  localData: Value(mutation.payload),
                  remoteData: Value(jsonEncode(serverData)),
                  conflictingUserId: Value(serverUpdatedBy),
                  conflictingUserName: Value(
                    serverData['updated_by_name'] ?? 'Unknown Technician',
                  ),
                ),
              );

              // We still update the server? User said "supervisor gets the UI if he and technitian have given data that is conflicting"
              // Usually supervisors "win" automatically in the UI, but here we save for review.
              // Let's NOT update yet, let the supervisor resolve it.
              throw Exception(
                'Conflict detected. Saved for supervisor review.',
              );
            }
          }
        }

        // No conflict, proceed with update
        if (mutation.mutationType == 'update') {
          await client.from(tableName).update(payload).eq('id', id);
        } else {
          await client.from(tableName).upsert(payload);
        }
        break;
      case 'delete':
        final id = payload['id'] as String;
        await client.from(_tableFor(mutation.entityType)).delete().eq('id', id);
        break;
      case 'file_upload':
        final localPath = payload['local_path'] as String;
        final entityType = payload['entity_type'] as String;
        final entityId = payload['entity_id'] as String;
        final fileName = payload['file_name'] as String;
        final fileSizeBytes = payload['file_size_bytes'] as int;

        final file = XFile(localPath);
        final fileBytes = await file.readAsBytes();

        final storagePath = '$entityType/$entityId/$fileName';

        await client.storage
            .from('attachments')
            .uploadBinary(
              storagePath,
              fileBytes,
              fileOptions: const FileOptions(upsert: true),
            );

        final publicUrl = client.storage
            .from('attachments')
            .getPublicUrl(storagePath);

        await client.from('attachments').insert({
          'entity_type': entityType,
          'entity_id': entityId,
          'file_path': publicUrl,
          'file_name': fileName,
          'file_size_bytes': fileSizeBytes,
        });
        break;
    }
  }

  /// Map entity type to Supabase table name.
  String _tableFor(String entityType) {
    switch (entityType) {
      case 'work_order':
        return 'work_orders';
      case 'inspection':
        return 'inspections';
      case 'asset':
        return 'assets';
      case 'comment':
        return 'work_order_comments';
      case 'attachment':
        return 'attachments';
      case 'work_order_material':
        return 'work_order_materials';
      default:
        return entityType;
    }
  }

  /// Mark the source entity as synced in its Drift table.
  Future<void> _markEntitySynced(String entityType, String entityId) async {
    switch (entityType) {
      case 'work_order':
        await _db.workOrderDao.markSynced(entityId);
        break;
      case 'inspection':
        await _db.inspectionDao.markSynced(entityId);
        break;
      case 'asset':
        await _db.assetDao.markSynced(entityId);
        break;
      case 'work_order_material':
        await (update(
          _db.workOrderMaterialEntries,
        )..where((t) => t.id.equals(entityId))).write(
          const WorkOrderMaterialEntriesCompanion(syncStatus: Value('synced')),
        );
        break;
    }
  }
}
