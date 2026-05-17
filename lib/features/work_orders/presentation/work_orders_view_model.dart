import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/di/injection.dart';
import '../../../core/error/failures.dart';
import '../../../core/mixins/crud_view_model_mixin.dart';
import '../../../core/storage/database_providers.dart';
import '../application/work_order_coordinator.dart';
import '../domain/work_order.dart';

part 'work_orders_view_model.g.dart';

/// Reactive local stream of all work orders.
final localWorkOrdersProvider = StreamProvider.autoDispose<List<WorkOrder>>((
  ref,
) {
  final db = ref.watch(sentraDatabaseProvider);
  return db.workOrderDao.watchAllWorkOrders().map(
    (rows) => rows.map((entry) => _fromEntry(entry)).toList(),
  );
});

/// Fetches a single work order by ID, checking local cache first.
final workOrderByIdProvider = FutureProvider.autoDispose
    .family<WorkOrder?, String>((ref, workOrderId) async {
      final localOrders = await ref.watch(localWorkOrdersProvider.future);
      final localMatch = localOrders
          .where((o) => o.id == workOrderId)
          .firstOrNull;
      if (localMatch != null) return localMatch;

      final coordinator = getIt<WorkOrderCoordinator>();
      final result = await coordinator.fetchWorkOrderById(workOrderId);
      return result.fold((_) => null, (workOrder) => workOrder);
    });

@riverpod
class WorkOrdersViewModel extends _$WorkOrdersViewModel
    with CrudViewModelMixin<WorkOrder> {
  late final WorkOrderCoordinator _coordinator;

  @override
  FutureOr<List<WorkOrder>> build() async {
    _coordinator = getIt<WorkOrderCoordinator>();
    return performFetch();
  }

  @override
  Future<Either<Failure, List<WorkOrder>>> fetchAll() =>
      _coordinator.fetchWorkOrders();

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    final result = await _coordinator.searchWorkOrders(query);
    state = result.fold(
      (l) => AsyncValue.error(l, StackTrace.current),
      (r) => AsyncValue.data(r),
    );
  }

  Future<void> create(WorkOrder workOrder) =>
      mutate(() => _coordinator.createWorkOrder(workOrder));

  Future<void> updateStatus(WorkOrder workOrder, WorkOrderStatus newStatus) =>
      mutate(() => _coordinator.updateWorkOrderStatus(workOrder, newStatus));
}

/// Helper to map Drift entry to Domain model.
WorkOrder _fromEntry(dynamic entry) {
  return WorkOrder(
    id: entry.id,
    title: entry.title,
    description: entry.description,
    status: WorkOrderStatus.values.firstWhere(
      (s) => s.name == entry.status,
      orElse: () => WorkOrderStatus.open,
    ),
    priority: WorkOrderPriority.values.firstWhere(
      (p) => p.name == entry.priority,
      orElse: () => WorkOrderPriority.medium,
    ),
    workType: WorkType.values
        .where((e) => e.name == entry.workType)
        .firstOrNull,
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
