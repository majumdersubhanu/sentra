import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/di/injection.dart';
import '../domain/work_order_comment.dart';
import '../domain/work_order_comment_repository.dart';

part 'work_order_comments_view_model.g.dart';

@riverpod
class WorkOrderComments extends _$WorkOrderComments {
  late final WorkOrderCommentRepository _repo;

  @override
  FutureOr<List<WorkOrderComment>> build(String workOrderId) async {
    _repo = getIt<WorkOrderCommentRepository>();
    final result = await _repo.getCommentsForWorkOrder(workOrderId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (comments) => comments,
    );
  }

  Future<void> addComment({
    required String content,
    String? authorId,
    String authorName = '',
  }) async {
    final comment = WorkOrderComment(
      id: 'CMT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      workOrderId: workOrderId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
    );

    await _repo.addComment(comment);
    ref.invalidateSelf(); // Refresh the comments list
  }
}
