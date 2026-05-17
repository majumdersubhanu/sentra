import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../domain/upload_repository.dart';

@lazySingleton
class UploadCoordinator {
  final UploadRepository _repository;

  UploadCoordinator(this._repository);

  Future<Either<Failure, List<UploadTask>>> fetchPendingQueue() {
    return _repository.getPendingUploads();
  }

  Future<Either<Failure, Unit>> retryTask(String taskId) {
    return _repository.retryUpload(taskId);
  }
}
