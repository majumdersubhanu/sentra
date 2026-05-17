import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import 'work_order.dart';

abstract interface class WorkOrderRepository {
  Future<Either<Failure, List<WorkOrder>>> getWorkOrders();
  Future<Either<Failure, WorkOrder>> getWorkOrderById(String id);
  Future<Either<Failure, Unit>> createWorkOrder(WorkOrder workOrder);
  Future<Either<Failure, Unit>> updateWorkOrder(WorkOrder workOrder);
}
