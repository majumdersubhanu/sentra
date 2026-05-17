import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';

enum UploadType { workOrder, inspectionForm, imageAttachment }

enum UploadState { pending, inProgress, failed, success }

class UploadTask {
  final String id;
  final UploadType type;
  final String localPayloadPath;
  final DateTime queuedAt;
  final UploadState state;
  final double progress;
  final String? errorMessage;

  const UploadTask({
    required this.id,
    required this.type,
    required this.localPayloadPath,
    required this.queuedAt,
    required this.state,
    this.progress = 0.0,
    this.errorMessage,
  });

  UploadTask copyWith({
    String? id,
    UploadType? type,
    String? localPayloadPath,
    DateTime? queuedAt,
    UploadState? state,
    double? progress,
    String? errorMessage,
  }) {
    return UploadTask(
      id: id ?? this.id,
      type: type ?? this.type,
      localPayloadPath: localPayloadPath ?? this.localPayloadPath,
      queuedAt: queuedAt ?? this.queuedAt,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

abstract interface class UploadRepository {
  Future<Either<Failure, List<UploadTask>>> getPendingUploads();
  Future<Either<Failure, Unit>> retryUpload(String taskId);
}
