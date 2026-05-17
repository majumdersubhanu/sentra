import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../domain/work_order_comment.dart';

/// Repository interface for work order comments.
abstract class WorkOrderCommentRepository {
  Future<Either<Failure, List<WorkOrderComment>>> getCommentsForWorkOrder(
    String workOrderId,
  );
  Future<Either<Failure, Unit>> addComment(WorkOrderComment comment);
}
