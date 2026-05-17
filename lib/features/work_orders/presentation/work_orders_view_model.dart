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

final localWorkOrdersProvider = StreamProvider.autoDispose<List<WorkOrder>>((
  ref,
) {
  final db = ref.watch(sentraDatabaseProvider);
  return db.workOrderDao.watchAllWorkOrders().map(
    (rows) => rows
        .map(
          (entry) => WorkOrder(
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
            scheduledDate: entry.scheduledDate ?? DateTime.now(),
            createdAt: entry.createdAt,
            assetId: entry.assetId,
            assignedTo: entry.assignedTo,
            organizationId: entry.organizationId,
          ),
        )
        .toList(),
  );
});

final workOrderByIdProvider = FutureProvider.autoDispose
    .family<WorkOrder?, String>((ref, workOrderId) async {
      final localOrders = await ref.watch(localWorkOrdersProvider.future);
      final localMatch = localOrders.where((o) => o.id == workOrderId).firstOrNull;
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

  Future<void> create(WorkOrder workOrder) =>
      mutate(() => _coordinator.createWorkOrder(workOrder));

  Future<void> updateStatus(WorkOrder workOrder, WorkOrderStatus newStatus) =>
      mutate(() => _coordinator.updateWorkOrderStatus(workOrder, newStatus));
}
