import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

/// Mixin that extracts the common fetch → refresh → mutate pattern
/// shared by all feature ViewModels.
///
/// Usage:
/// ```dart
/// class WorkOrdersViewModel extends AsyncNotifier<List<WorkOrder>>
///     with CrudViewModelMixin<WorkOrder> {
///   @override
///   Future<Either<Failure, List<WorkOrder>>> fetchAll() =>
///       _coordinator.fetchWorkOrders();
/// }
/// ```
mixin CrudViewModelMixin<T> {
  AsyncValue<List<T>> get state;
  set state(AsyncValue<List<T>> value);

  /// Override this to provide the data-fetching call for the feature.
  Future<Either<Failure, List<T>>> fetchAll();

  /// Fetches data and folds the Either result.
  Future<List<T>> performFetch() async {
    final result = await fetchAll();
    return result.fold((failure) => throw failure.message, (items) => items);
  }

  /// Refreshes the list state.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(performFetch);
  }

  /// Executes a mutation (create/update/delete) and refreshes on success.
  Future<void> mutate(Future<Either<Failure, Unit>> Function() action) async {
    final result = await action();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => refresh(),
    );
  }
}
