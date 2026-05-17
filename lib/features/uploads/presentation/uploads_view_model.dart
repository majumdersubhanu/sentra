import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/di/injection.dart';
import '../../../core/error/failures.dart';
import '../../../core/mixins/crud_view_model_mixin.dart';
import '../application/upload_coordinator.dart';
import '../domain/upload_repository.dart';

part 'uploads_view_model.g.dart';

@riverpod
class UploadsViewModel extends _$UploadsViewModel
    with CrudViewModelMixin<UploadTask> {
  late final UploadCoordinator _coordinator;

  @override
  FutureOr<List<UploadTask>> build() async {
    _coordinator = getIt<UploadCoordinator>();
    return performFetch();
  }

  @override
  Future<Either<Failure, List<UploadTask>>> fetchAll() =>
      _coordinator.fetchPendingQueue();

  Future<void> retry(String taskId) =>
      mutate(() => _coordinator.retryTask(taskId));
}
