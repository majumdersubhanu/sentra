import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../domain/work_order.dart';
import '../domain/work_order_repository.dart';

@lazySingleton
class WorkOrderCoordinator {
  final WorkOrderRepository _repository;

  WorkOrderCoordinator(this._repository);

  Future<Either<Failure, List<WorkOrder>>> fetchWorkOrders() {
    return _repository.getWorkOrders();
  }

  Future<Either<Failure, WorkOrder>> fetchWorkOrderById(String id) {
    return _repository.getWorkOrderById(id);
  }

  Future<Either<Failure, Unit>> createWorkOrder(WorkOrder workOrder) {
    return _repository.createWorkOrder(workOrder);
  }

  Future<Either<Failure, Unit>> updateWorkOrderStatus(
    WorkOrder workOrder,
    WorkOrderStatus newStatus,
  ) {
    final updated = workOrder.copyWith(status: newStatus);
    return _repository.updateWorkOrder(updated);
  }

  Future<Either<Failure, List<WorkOrder>>> searchWorkOrders(String query) {
    return _repository.searchWorkOrders(query);
  }

  Future<Either<Failure, List<WorkOrderMaterial>>> fetchWorkOrderMaterials(
    String workOrderId,
  ) {
    return _repository.getWorkOrderMaterials(workOrderId);
  }
}
