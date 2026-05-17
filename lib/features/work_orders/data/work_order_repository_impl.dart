import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/env/env.dart';
import '../../../core/error/failures.dart';
import '../../../core/storage/database.dart';
import '../domain/work_order.dart';
import '../domain/work_order_repository.dart';

/// Network-aware repository: reads from Supabase when online, falls back to
/// Drift when offline. All writes go to Drift first, then sync to Supabase.
@LazySingleton(as: WorkOrderRepository)
class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final SentraDatabase _db;

  WorkOrderRepositoryImpl(this._db);

  // ─── Mock data for bypass mode ──────────────────────────────────────────

  static final List<WorkOrder> _mockWorkOrders = [
    WorkOrder(
      id: 'WO-1001',
      title: 'HVAC Compressor Inspection',
      description:
          'Check pressure levels and replace air filters on main HVAC unit.',
      status: WorkOrderStatus.open,
      priority: WorkOrderPriority.high,
      scheduledDate: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      assetId: 'AST-502',
    ),
    WorkOrder(
      id: 'WO-1002',
      title: 'Substation Transformer Calibration',
      description:
          'Perform standard thermal imaging and voltage drop calibration tests.',
      status: WorkOrderStatus.inProgress,
      priority: WorkOrderPriority.urgent,
      scheduledDate: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      assetId: 'AST-104',
    ),
    WorkOrder(
      id: 'WO-1003',
      title: 'Perimeter Security Gate Alignment',
      description:
          'Lubricate mechanical tracks and realign optical safety sensors.',
      status: WorkOrderStatus.completed,
      priority: WorkOrderPriority.medium,
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      assetId: 'AST-882',
    ),
  ];

  // Keep a mutable list for bypass mode CRUD
  final List<WorkOrder> _localMockOrders = List.from(_mockWorkOrders);

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // ─── READ ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<WorkOrder>>> getWorkOrders() async {
    if (Env.bypassAuth) {
      return Right(List.unmodifiable(_localMockOrders));
    }

    try {
      // Try Supabase first
      final client = _client;
      if (client != null) {
        final response = await client
            .from('work_orders')
            .select()
            .order('created_at', ascending: false);

        final workOrders = (response as List)
            .map((json) => _fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache to Drift in background
        _cacheToLocal(workOrders);

        return Right(workOrders);
      }
    } catch (_) {
      // Network failed — fall through to local
    }

    // Offline fallback: read from Drift
    try {
      final entries = await _db.workOrderDao.getAllWorkOrders();
      return Right(entries.map(_fromEntry).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to read local cache: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkOrder>> getWorkOrderById(String id) async {
    if (Env.bypassAuth) {
      final wo = _localMockOrders.where((w) => w.id == id).firstOrNull;
      if (wo != null) return Right(wo);
      return const Left(CacheFailure('Work order not found.'));
    }

    try {
      final client = _client;
      if (client != null) {
        final response = await client
            .from('work_orders')
            .select()
            .eq('id', id)
            .single();
        return Right(_fromJson(response));
      }
    } catch (_) {}

    try {
      final entry = await _db.workOrderDao.getById(id);
      if (entry != null) return Right(_fromEntry(entry));
      return const Left(CacheFailure('Work order not found locally.'));
    } catch (e) {
      return Left(CacheFailure('Failed to read local cache: $e'));
    }
  }

  // ─── WRITE (Drift-first, enqueue sync) ──────────────────────────────────

  @override
  Future<Either<Failure, Unit>> createWorkOrder(WorkOrder workOrder) async {
    if (Env.bypassAuth) {
      _localMockOrders.add(workOrder);
      return const Right(unit);
    }

    try {
      // Write to Drift
      await _db.workOrderDao.upsertWorkOrder(
        _toCompanion(workOrder, syncStatus: 'pending'),
      );

      // Enqueue sync mutation
      await _db.syncQueueDao.enqueue(
        entityType: 'work_order',
        entityId: workOrder.id,
        mutationType: 'create',
        payload: jsonEncode(_toJson(workOrder)),
      );

      // Try immediate Supabase sync
      try {
        final client = _client;
        if (client != null) {
          await client.from('work_orders').insert(_toJson(workOrder));
          await _db.workOrderDao.markSynced(workOrder.id);
        }
      } catch (_) {
        // Will sync later via SyncEngine
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to create work order: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateWorkOrder(WorkOrder workOrder) async {
    if (Env.bypassAuth) {
      final index = _localMockOrders.indexWhere((w) => w.id == workOrder.id);
      if (index != -1) {
        _localMockOrders[index] = workOrder;
        return const Right(unit);
      }
      return const Left(CacheFailure('Work order not found to update.'));
    }

    try {
      await _db.workOrderDao.upsertWorkOrder(
        _toCompanion(workOrder, syncStatus: 'pending'),
      );

      await _db.syncQueueDao.enqueue(
        entityType: 'work_order',
        entityId: workOrder.id,
        mutationType: 'update',
        payload: jsonEncode(_toJson(workOrder)),
      );

      try {
        final client = _client;
        if (client != null) {
          await client
              .from('work_orders')
              .update(_toJson(workOrder))
              .eq('id', workOrder.id);
          await _db.workOrderDao.markSynced(workOrder.id);
        }
      } catch (_) {}

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update work order: $e'));
    }
  }

  // ─── Cache Invalidation ─────────────────────────────────────────────────

  /// Saves remote data to local Drift cache.
  Future<void> _cacheToLocal(List<WorkOrder> orders) async {
    try {
      final companions = orders
          .map((wo) => _toCompanion(wo, syncStatus: 'synced'))
          .toList();
      await _db.workOrderDao.bulkUpsert(companions);
    } catch (_) {
      // Non-critical: cache miss is acceptable
    }
  }

  // ─── Mapping ────────────────────────────────────────────────────────────

  static WorkOrder _fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      priority: _parsePriority(json['priority'] as String?),
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      assetId: json['asset_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      organizationId: json['organization_id'] as String?,
    );
  }

  static Map<String, dynamic> _toJson(WorkOrder wo) {
    return {
      'id': wo.id,
      'title': wo.title,
      'description': wo.description,
      'status': wo.status.name,
      'priority': wo.priority.name,
      'scheduled_date': wo.scheduledDate.toIso8601String(),
      'asset_id': wo.assetId,
      'assigned_to': wo.assignedTo,
      'organization_id': wo.organizationId,
    };
  }

  static WorkOrder _fromEntry(WorkOrderEntry entry) {
    return WorkOrder(
      id: entry.id,
      title: entry.title,
      description: entry.description,
      status: _parseStatus(entry.status),
      priority: _parsePriority(entry.priority),
      scheduledDate: entry.scheduledDate ?? DateTime.now(),
      createdAt: entry.createdAt,
      assetId: entry.assetId,
      assignedTo: entry.assignedTo,
      organizationId: entry.organizationId,
    );
  }

  static WorkOrderEntriesCompanion _toCompanion(
    WorkOrder wo, {
    required String syncStatus,
  }) {
    return WorkOrderEntriesCompanion(
      id: Value(wo.id),
      title: Value(wo.title),
      description: Value(wo.description),
      status: Value(wo.status.name),
      priority: Value(wo.priority.name),
      scheduledDate: Value(wo.scheduledDate),
      createdAt: Value(wo.createdAt),
      assetId: Value(wo.assetId),
      assignedTo: Value(wo.assignedTo),
      organizationId: Value(wo.organizationId),
      syncStatus: Value(syncStatus),
    );
  }

  static WorkOrderStatus _parseStatus(String? status) {
    return WorkOrderStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => WorkOrderStatus.open,
    );
  }

  static WorkOrderPriority _parsePriority(String? priority) {
    return WorkOrderPriority.values.firstWhere(
      (p) => p.name == priority,
      orElse: () => WorkOrderPriority.medium,
    );
  }
}
