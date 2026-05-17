import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../storage/database.dart';
import 'package:drift/drift.dart';

/// Listens to Supabase Realtime changes and reflects them in the local database.
class RealtimeService {
  final SentraDatabase _db;
  final SupabaseClient _client;

  RealtimeChannel? _channel;
  bool _isListening = false;

  RealtimeService(this._db, this._client);

  /// Start listening to realtime changes.
  void start() {
    if (_isListening) return;
    _isListening = true;

    _channel = _client.channel('public:any')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'work_orders',
        callback: (payload) => _handleWorkOrderChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'inspections',
        callback: (payload) => _handleInspectionChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'assets',
        callback: (payload) => _handleAssetChange(payload),
      )
      ..subscribe();

    if (kDebugMode) {
      debugPrint('[Realtime] Subscribed to changes');
    }
  }

  /// Stop listening.
  void stop() {
    _channel?.unsubscribe();
    _isListening = false;
  }

  Future<void> _handleWorkOrderChange(PostgresChangePayload payload) async {
    final json = payload.newRecord;
    final id = (json['id'] ?? payload.oldRecord['id']) as String;

    if (payload.eventType == PostgresChangeEvent.delete) {
      await _db.workOrderDao.deleteById(id);
      return;
    }

    // Check for local conflict
    final local = await _db.workOrderDao.getById(id);
    if (local != null && local.syncStatus == 'pending') {
      await _db.conflictDao.upsertConflict(
        ConflictEntriesCompanion(
          id: Value(id),
          entityType: const Value('work_order'),
          localData: Value(jsonEncode(local.toJson())),
          remoteData: Value(jsonEncode(json)),
          conflictingUserId: Value(json['updated_by'] as String?),
          conflictingUserName: Value(
            json['updated_by_name'] as String? ?? 'Unknown Technician',
          ),
        ),
      );
      return;
    }

    // Server wins / Simple sync
    await _db.workOrderDao.upsertWorkOrder(
      WorkOrderEntriesCompanion(
        id: Value(id),
        title: Value(json['title'] as String),
        description: Value(json['description'] as String? ?? ''),
        status: Value(json['status'] as String),
        priority: Value(json['priority'] as String),
        scheduledDate: Value(DateTime.parse(json['scheduled_date'] as String)),
        createdAt: Value(DateTime.parse(json['created_at'] as String)),
        assetId: Value(json['asset_id'] as String?),
        assignedTo: Value(json['assigned_to'] as String?),
        organizationId: Value(json['organization_id'] as String?),
        syncStatus: const Value('synced'),
      ),
    );
  }

  Future<void> _handleInspectionChange(PostgresChangePayload payload) async {
    final json = payload.newRecord;
    final id = (json['id'] ?? payload.oldRecord['id']) as String;

    if (payload.eventType == PostgresChangeEvent.delete) {
      await _db.inspectionDao.deleteById(id);
      return;
    }

    // Basic sync (inspections are usually only updated by one person, less conflict prone)
    await _db.inspectionDao.upsertInspection(
      InspectionEntriesCompanion(
        id: Value(id),
        templateName: Value(json['template_name'] as String),
        workOrderId: Value(json['work_order_id'] as String),
        inspectorName: Value(json['inspector_name'] as String),
        status: Value(json['status'] as String),
        createdAt: Value(DateTime.parse(json['created_at'] as String)),
        submittedBy: Value(json['submitted_by'] as String?),
        organizationId: Value(json['organization_id'] as String?),
        syncStatus: const Value('synced'),
      ),
    );
  }

  Future<void> _handleAssetChange(PostgresChangePayload payload) async {
    final json = payload.newRecord;
    final id = (json['id'] ?? payload.oldRecord['id']) as String;

    if (payload.eventType == PostgresChangeEvent.delete) {
      await _db.assetDao.deleteById(id);
      return;
    }

    await _db.assetDao.upsertAsset(
      AssetEntriesCompanion(
        id: Value(id),
        name: Value(json['name'] as String),
        qrCode: Value(json['qr_code'] as String? ?? ''),
        modelNumber: Value(json['model_number'] as String? ?? ''),
        serialNumber: Value(json['serial_number'] as String? ?? ''),
        locationCoordinates: Value(
          json['location_coordinates'] as String? ?? '',
        ),
        status: Value(json['status'] as String),
        lastMaintenanceDate: Value(
          json['last_maintenance_date'] != null
              ? DateTime.parse(json['last_maintenance_date'] as String)
              : null,
        ),
        createdAt: Value(DateTime.parse(json['created_at'] as String)),
        organizationId: Value(json['organization_id'] as String?),
        syncStatus: const Value('synced'),
      ),
    );
  }
}
