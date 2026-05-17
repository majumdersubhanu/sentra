import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/env/env.dart';
import '../../../core/error/failures.dart';
import '../domain/work_order_comment.dart';
import '../domain/work_order_comment_repository.dart';

@LazySingleton(as: WorkOrderCommentRepository)
class WorkOrderCommentRepositoryImpl implements WorkOrderCommentRepository {
  // Mock data for bypass mode
  final List<WorkOrderComment> _mockComments = [
    WorkOrderComment(
      id: 'CMT-001',
      workOrderId: 'WO-1001',
      authorName: 'Subhanu',
      content:
          'Noticed irregular vibration on compressor startup. Will investigate during inspection.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    WorkOrderComment(
      id: 'CMT-002',
      workOrderId: 'WO-1001',
      authorName: 'Elena Rostova',
      content:
          'Filter replacement kit has been staged at Building B. Confirm receipt before proceeding.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    WorkOrderComment(
      id: 'CMT-003',
      workOrderId: 'WO-1002',
      authorName: 'Subhanu',
      content:
          'Thermal imaging camera calibrated and ready. Starting at 1400 hours.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<WorkOrderComment>>> getCommentsForWorkOrder(
    String workOrderId,
  ) async {
    if (Env.bypassAuth) {
      return Right(
        _mockComments.where((c) => c.workOrderId == workOrderId).toList(),
      );
    }

    try {
      final client = _client;
      if (client == null) {
        return Right(
          _mockComments.where((c) => c.workOrderId == workOrderId).toList(),
        );
      }

      final response = await client
          .from('work_order_comments')
          .select()
          .eq('work_order_id', workOrderId)
          .order('created_at', ascending: true);

      final comments = (response as List)
          .map((json) => _fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(comments);
    } catch (e) {
      return Left(NetworkFailure('Failed to fetch comments: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addComment(WorkOrderComment comment) async {
    if (Env.bypassAuth) {
      _mockComments.add(comment);
      return const Right(unit);
    }

    try {
      final client = _client;
      if (client == null) {
        return const Left(NetworkFailure('Supabase client not initialized.'));
      }

      await client.from('work_order_comments').insert({
        'work_order_id': comment.workOrderId,
        'author_id': comment.authorId,
        'author_name': comment.authorName,
        'content': comment.content,
      });

      return const Right(unit);
    } catch (e) {
      return Left(NetworkFailure('Failed to add comment: $e'));
    }
  }

  static WorkOrderComment _fromJson(Map<String, dynamic> json) {
    return WorkOrderComment(
      id: json['id'] as String,
      workOrderId: json['work_order_id'] as String,
      authorId: json['author_id'] as String?,
      authorName: json['author_name'] as String? ?? '',
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
