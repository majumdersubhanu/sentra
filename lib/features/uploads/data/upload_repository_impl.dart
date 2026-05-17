import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/env/env.dart';
import '../../../core/error/failures.dart';
import '../domain/upload_repository.dart';

@LazySingleton(as: UploadRepository)
class UploadRepositoryImpl implements UploadRepository {
  // Local mock data for offline/bypass mode
  final List<UploadTask> _localTasks = [
    UploadTask(
      id: 'UP-001',
      type: UploadType.inspectionForm,
      localPayloadPath: '/offline_cache/ins_2001_payload.json',
      queuedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      state: UploadState.failed,
      progress: 0.35,
      errorMessage: 'Network timeout during blob part initialization.',
    ),
    UploadTask(
      id: 'UP-002',
      type: UploadType.imageAttachment,
      localPayloadPath: '/offline_cache/images/img_compressor_leak.jpg',
      queuedAt: DateTime.now().subtract(const Duration(minutes: 44)),
      state: UploadState.pending,
      progress: 0.0,
    ),
    UploadTask(
      id: 'UP-003',
      type: UploadType.workOrder,
      localPayloadPath: '/offline_cache/wo_1009_create.json',
      queuedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      state: UploadState.inProgress,
      progress: 0.72,
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
  Future<Either<Failure, List<UploadTask>>> getPendingUploads() async {
    if (Env.bypassAuth) {
      return Right(List.unmodifiable(_localTasks));
    }

    try {
      final client = _client;
      if (client == null) {
        return Right(List.unmodifiable(_localTasks));
      }

      final response = await client
          .from('sync_queue')
          .select()
          .neq('status', 'success')
          .order('created_at', ascending: false);

      final tasks = (response as List)
          .map((json) => _fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(tasks);
    } catch (e) {
      return Left(
        NetworkFailure('Failed to fetch upload queue: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> retryUpload(String taskId) async {
    if (Env.bypassAuth) {
      final index = _localTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _localTasks[index] = _localTasks[index].copyWith(
          state: UploadState.success,
          progress: 1.0,
          errorMessage: null,
        );
        return const Right(unit);
      }
      return const Left(CacheFailure('Task identifier not present in queue.'));
    }

    try {
      final client = _client;
      if (client == null) {
        return const Left(NetworkFailure('Supabase client not initialized.'));
      }

      await client
          .from('sync_queue')
          .update({'status': 'pending'})
          .eq('id', taskId);

      return const Right(unit);
    } catch (e) {
      return Left(UploadFailure('Failed to retry upload: ${e.toString()}'));
    }
  }

  // --- JSON Mapping ---

  static UploadTask _fromJson(Map<String, dynamic> json) {
    return UploadTask(
      id: json['id'] as String,
      type: _parseType(json['mutation_type'] as String?),
      localPayloadPath: '',
      queuedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      state: _parseState(json['status'] as String?),
      progress: 0.0,
    );
  }

  static UploadType _parseType(String? type) {
    switch (type) {
      case 'work_order':
        return UploadType.workOrder;
      case 'inspection':
        return UploadType.inspectionForm;
      case 'image':
        return UploadType.imageAttachment;
      default:
        return UploadType.workOrder;
    }
  }

  static UploadState _parseState(String? state) {
    return UploadState.values.firstWhere(
      (s) => s.name == state,
      orElse: () => UploadState.pending,
    );
  }
}
