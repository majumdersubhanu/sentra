import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/di/injection.dart';
import '../../../core/error/failures.dart';
import '../../../core/mixins/crud_view_model_mixin.dart';
import '../../../core/storage/database_providers.dart';
import '../application/inspection_coordinator.dart';
import '../domain/inspection.dart';

part 'inspections_view_model.g.dart';

final localInspectionsProvider = StreamProvider.autoDispose<List<Inspection>>((
  ref,
) {
  final db = ref.watch(sentraDatabaseProvider);
  return db.inspectionDao.watchAllInspections().asyncMap((rows) async {
    final inspections = <Inspection>[];
    for (final entry in rows) {
      final items = await db.inspectionDao.getItemsForInspection(entry.id);
      inspections.add(
        Inspection(
          id: entry.id,
          templateName: entry.templateName,
          workOrderId: entry.workOrderId,
          inspectorName: entry.inspectorName,
          createdAt: entry.createdAt,
          status: InspectionStatus.values.firstWhere(
            (s) => s.name == entry.status,
            orElse: () => InspectionStatus.draft,
          ),
          submittedBy: entry.submittedBy,
          organizationId: entry.organizationId,
          items: items
              .map(
                (item) => InspectionItem(
                  id: item.id,
                  question: item.question,
                  isPass: item.isPass,
                  comments: item.comments,
                  sortOrder: item.sortOrder,
                ),
              )
              .toList(),
        ),
      );
    }
    return inspections;
  });
});

@riverpod
class InspectionsViewModel extends _$InspectionsViewModel
    with CrudViewModelMixin<Inspection> {
  late final InspectionCoordinator _coordinator;

  @override
  FutureOr<List<Inspection>> build() async {
    _coordinator = getIt<InspectionCoordinator>();
    return performFetch();
  }

  @override
  Future<Either<Failure, List<Inspection>>> fetchAll() =>
      _coordinator.fetchInspections();

  Future<void> submit(Inspection inspection) =>
      mutate(() => _coordinator.submitInspection(inspection));
}
