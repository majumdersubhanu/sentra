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
      workType: WorkType.inspection,
      siteLocation: 'Building A - Roof',
      scheduledStart: DateTime.now().add(const Duration(hours: 2)),
      scheduledFinish: DateTime.now().add(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      assetId: 'AST-502',
    ),
    WorkOrder(
      id: 'WO-1002',
      title: 'Substation Transformer Calibration',
      description:
          'Perform standard thermal imaging and voltage drop calibration tests.',
      status: WorkOrderStatus.inProgress,
      priority: WorkOrderPriority.critical,
      workType: WorkType.preventive,
      siteLocation: 'East Substation',
      scheduledStart: DateTime.now().subtract(const Duration(hours: 1)),
      scheduledFinish: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      assetId: 'AST-104',
    ),
  ];

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
    if (Env.bypassAuth) return Right(List.unmodifiable(_localMockOrders));

    try {
      final client = _client;
      if (client != null) {
        final response = await client
            .from('work_orders')
            .select()
            .order('created_at', ascending: false);
        final workOrders = (response as List)
            .map((json) => _fromJson(json as Map<String, dynamic>))
            .toList();
        _cacheToLocal(workOrders);
        return Right(workOrders);
      }
    } catch (_) {}

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

  @override
  Future<Either<Failure, List<WorkOrder>>> searchWorkOrders(
    String query,
  ) async {
    if (Env.bypassAuth) {
      final filtered = _localMockOrders
          .where(
            (wo) =>
                wo.title.toLowerCase().contains(query.toLowerCase()) ||
                wo.description.toLowerCase().contains(query.toLowerCase()) ||
                wo.id.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      return Right(filtered);
    }

    try {
      final q = query.toLowerCase();
      final entries =
          await (_db.select(_db.workOrderEntries)..where(
                (t) =>
                    t.title.lower().contains(q) |
                    t.description.lower().contains(q) |
                    t.id.lower().contains(q) |
                    t.siteLocation.lower().contains(q),
              ))
              .get();
      return Right(entries.map(_fromEntry).toList());
    } catch (e) {
      return Left(CacheFailure('Search failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkOrderMaterial>>> getWorkOrderMaterials(
    String workOrderId,
  ) async {
    try {
      final materials = await (_db.select(
        _db.workOrderMaterialEntries,
      )..where((t) => t.workOrderId.equals(workOrderId))).get();
      return Right(
        materials
            .map(
              (m) => WorkOrderMaterial(
                id: m.id,
                workOrderId: m.workOrderId,
                partNumber: m.partNumber,
                description: m.description,
                quantity: m.quantity,
                unitOfMeasure: m.unitOfMeasure,
                unitCost: m.unitCost,
                warehouseLocation: m.warehouseLocation,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to fetch materials: $e'));
    }
  }

  // ─── WRITE ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> createWorkOrder(WorkOrder workOrder) async {
    if (Env.bypassAuth) {
      _localMockOrders.add(workOrder);
      return const Right(unit);
    }

    try {
      await _db.workOrderDao.upsertWorkOrder(
        _toCompanion(workOrder, syncStatus: 'pending'),
      );
      await _db.syncQueueDao.enqueue(
        entityType: 'work_order',
        entityId: workOrder.id,
        mutationType: 'create',
        payload: jsonEncode(_toJson(workOrder)),
      );

      try {
        final client = _client;
        if (client != null) {
          await client.from('work_orders').insert(_toJson(workOrder));
          await _db.workOrderDao.markSynced(workOrder.id);
        }
      } catch (_) {}

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

  // ─── MAPPING ────────────────────────────────────────────────────────────

  static WorkOrder _fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: _parseEnum(
        WorkOrderStatus.values,
        json['status'] as String?,
        WorkOrderStatus.open,
      ),
      priority: _parseEnum(
        WorkOrderPriority.values,
        json['priority'] as String?,
        WorkOrderPriority.medium,
      ),
      workType: _parseEnum(WorkType.values, json['work_type'] as String?, null),
      parentWorkOrderId: json['parent_work_order_id'] as String?,
      serviceRequestId: json['service_request_id'] as String?,
      maintenanceStrategy: json['maintenance_strategy'] as String?,
      riskClassification: json['risk_classification'] as String?,
      workflowStage: json['workflow_stage'] as String?,
      scheduledDate: _parseDate(json['scheduled_date']),
      scheduledStart: _parseDate(json['scheduled_start']),
      scheduledFinish: _parseDate(json['scheduled_finish']),
      slaTarget: _parseDate(json['sla_target']),
      estimatedLaborHours: (json['estimated_labor_hours'] as num?)?.toDouble(),
      siteRegion: json['site_region'] as String?,
      siteLocation: json['site_location'] as String?,
      gpsCoordinates: json['gps_coordinates'] as String?,
      businessUnit: json['business_unit'] as String?,
      department: json['department'] as String?,
      costCenter: json['cost_center'] as String?,
      permitRequirement: json['permit_requirement'] as bool? ?? false,
      confinedSpaceEntry: json['confined_space_entry'] as bool? ?? false,
      hotWorkRequired: json['hot_work_required'] as bool? ?? false,
      lockoutTagoutRequired: json['lockout_tagout_required'] as bool? ?? false,
      environmentalSensitivity: json['environmental_sensitivity'] as String?,
      regulatoryComplianceScope: json['regulatory_compliance_scope'] as String?,
      escalationTier: json['escalation_tier'] as String?,
      requestedBy: json['requested_by'] as String?,
      reportedThrough: json['reported_through'] as String?,
      customerImpact: json['customer_impact'] as String?,
      impactSeverity: json['impact_severity'] as String?,
      actualStart: _parseDate(json['actual_start']),
      actualFinish: _parseDate(json['actual_finish']),
      technicianNotes: json['technician_notes'] as String?,
      customerSignaturePath: json['customer_signature_path'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
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
      'work_type': wo.workType?.name,
      'parent_work_order_id': wo.parentWorkOrderId,
      'service_request_id': wo.serviceRequestId,
      'maintenance_strategy': wo.maintenanceStrategy,
      'risk_classification': wo.riskClassification,
      'workflow_stage': wo.workflowStage,
      'scheduled_date': wo.scheduledDate?.toIso8601String(),
      'scheduled_start': wo.scheduledStart?.toIso8601String(),
      'scheduled_finish': wo.scheduledFinish?.toIso8601String(),
      'sla_target': wo.slaTarget?.toIso8601String(),
      'estimated_labor_hours': wo.estimatedLaborHours,
      'site_region': wo.siteRegion,
      'site_location': wo.siteLocation,
      'gps_coordinates': wo.gpsCoordinates,
      'business_unit': wo.businessUnit,
      'department': wo.department,
      'cost_center': wo.costCenter,
      'permit_requirement': wo.permitRequirement,
      'confined_space_entry': wo.confinedSpaceEntry,
      'hot_work_required': wo.hotWorkRequired,
      'lockout_tagout_required': wo.lockoutTagoutRequired,
      'environmental_sensitivity': wo.environmentalSensitivity,
      'regulatory_compliance_scope': wo.regulatoryComplianceScope,
      'escalation_tier': wo.escalationTier,
      'requested_by': wo.requestedBy,
      'reported_through': wo.reportedThrough,
      'customer_impact': wo.customerImpact,
      'impact_severity': wo.impactSeverity,
      'actual_start': wo.actualStart?.toIso8601String(),
      'actual_finish': wo.actualFinish?.toIso8601String(),
      'technician_notes': wo.technicianNotes,
      'customer_signature_path': wo.customerSignaturePath,
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
      status: _parseEnum(
        WorkOrderStatus.values,
        entry.status,
        WorkOrderStatus.open,
      ),
      priority: _parseEnum(
        WorkOrderPriority.values,
        entry.priority,
        WorkOrderPriority.medium,
      ),
      workType: _parseEnum(WorkType.values, entry.workType, null),
      parentWorkOrderId: entry.parentWorkOrderId,
      serviceRequestId: entry.serviceRequestId,
      maintenanceStrategy: entry.maintenanceStrategy,
      riskClassification: entry.riskClassification,
      workflowStage: entry.workflowStage,
      scheduledDate: entry.scheduledDate,
      scheduledStart: entry.scheduledStart,
      scheduledFinish: entry.scheduledFinish,
      slaTarget: entry.slaTarget,
      estimatedLaborHours: entry.estimatedLaborHours,
      siteRegion: entry.siteRegion,
      siteLocation: entry.siteLocation,
      gpsCoordinates: entry.gpsCoordinates,
      businessUnit: entry.businessUnit,
      department: entry.department,
      costCenter: entry.costCenter,
      permitRequirement: entry.permitRequirement,
      confinedSpaceEntry: entry.confinedSpaceEntry,
      hotWorkRequired: entry.hotWorkRequired,
      lockoutTagoutRequired: entry.lockoutTagoutRequired,
      environmentalSensitivity: entry.environmentalSensitivity,
      regulatoryComplianceScope: entry.regulatoryComplianceScope,
      escalationTier: entry.escalationTier,
      requestedBy: entry.requestedBy,
      reportedThrough: entry.reportedThrough,
      customerImpact: entry.customerImpact,
      impactSeverity: entry.impactSeverity,
      actualStart: entry.actualStart,
      actualFinish: entry.actualFinish,
      technicianNotes: entry.technicianNotes,
      customerSignaturePath: entry.customerSignaturePath,
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
      workType: Value(wo.workType?.name),
      parentWorkOrderId: Value(wo.parentWorkOrderId),
      serviceRequestId: Value(wo.serviceRequestId),
      maintenanceStrategy: Value(wo.maintenanceStrategy),
      riskClassification: Value(wo.riskClassification),
      workflowStage: Value(wo.workflowStage),
      scheduledDate: Value(wo.scheduledDate),
      scheduledStart: Value(wo.scheduledStart),
      scheduledFinish: Value(wo.scheduledFinish),
      slaTarget: Value(wo.slaTarget),
      estimatedLaborHours: Value(wo.estimatedLaborHours),
      siteRegion: Value(wo.siteRegion),
      siteLocation: Value(wo.siteLocation),
      gpsCoordinates: Value(wo.gpsCoordinates),
      businessUnit: Value(wo.businessUnit),
      department: Value(wo.department),
      costCenter: Value(wo.costCenter),
      permitRequirement: Value(wo.permitRequirement),
      confinedSpaceEntry: Value(wo.confinedSpaceEntry),
      hotWorkRequired: Value(wo.hotWorkRequired),
      lockoutTagoutRequired: Value(wo.lockoutTagoutRequired),
      environmentalSensitivity: Value(wo.environmentalSensitivity),
      regulatoryComplianceScope: Value(wo.regulatoryComplianceScope),
      escalationTier: Value(wo.escalationTier),
      requestedBy: Value(wo.requestedBy),
      reportedThrough: Value(wo.reportedThrough),
      customerImpact: Value(wo.customerImpact),
      impactSeverity: Value(wo.impactSeverity),
      actualStart: Value(wo.actualStart),
      actualFinish: Value(wo.actualFinish),
      technicianNotes: Value(wo.technicianNotes),
      customerSignaturePath: Value(wo.customerSignaturePath),
      createdAt: Value(wo.createdAt),
      assetId: Value(wo.assetId),
      assignedTo: Value(wo.assignedTo),
      organizationId: Value(wo.organizationId),
      syncStatus: Value(syncStatus),
    );
  }

  static T _parseEnum<T extends Enum>(
    List<T> values,
    String? name,
    T defaultValue,
  ) {
    if (name == null) return defaultValue;
    return values.firstWhere((e) => e.name == name, orElse: () => defaultValue);
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    return DateTime.tryParse(date as String);
  }

  Future<void> _cacheToLocal(List<WorkOrder> orders) async {
    try {
      final companions = orders
          .map((wo) => _toCompanion(wo, syncStatus: 'synced'))
          .toList();
      await _db.workOrderDao.bulkUpsert(companions);
    } catch (_) {}
  }
}
