import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../core/storage/database.dart';
import '../domain/inspection.dart';
import '../domain/inspection_repository.dart';

@LazySingleton(as: InspectionRepository)
class InspectionRepositoryImpl implements InspectionRepository {
  final SentraDatabase _db;

  InspectionRepositoryImpl(this._db);

  @override
  Future<Either<Failure, List<Inspection>>> getInspections() async {
    try {
      final entries = await _db.inspectionDao.getAllInspections();
      final inspections = <Inspection>[];
      for (final entry in entries) {
        final items = await _db.inspectionDao.getItemsForInspection(entry.id);
        inspections.add(_fromEntry(entry, items));
      }
      return Right(inspections);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveInspection(Inspection inspection) async {
    try {
      await _db.inspectionDao.upsertInspection(
        _toCompanion(inspection, syncStatus: 'pending'),
      );

      final items = inspection.items
          .map(
            (i) => InspectionItemEntriesCompanion(
              id: Value(i.id),
              inspectionId: Value(inspection.id),
              question: Value(i.question),
              isPass: Value(i.isPass),
              comments: Value(i.comments),
              sortOrder: Value(i.sortOrder),
            ),
          )
          .toList();

      for (final item in items) {
        await _db.into(_db.inspectionItemEntries).insertOnConflictUpdate(item);
      }

      await _db.syncQueueDao.enqueue(
        entityType: 'inspection',
        entityId: inspection.id,
        mutationType: 'create',
        payload: jsonEncode(_toJson(inspection)),
      );

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Inspection _fromEntry(
    InspectionEntry entry,
    List<InspectionItemEntry> items,
  ) {
    return Inspection(
      id: entry.id,
      templateName: entry.templateName,
      workOrderId: entry.workOrderId ?? '',
      inspectorName: entry.inspectorName,
      createdAt: entry.createdAt,
      status: _parseStatus(entry.status),
      submittedBy: entry.submittedBy,
      organizationId: entry.organizationId,
      items: items
          .map(
            (i) => InspectionItem(
              id: i.id,
              question: i.question,
              isPass: i.isPass,
              comments: i.comments,
              sortOrder: i.sortOrder,
            ),
          )
          .toList(),
    );
  }

  static InspectionEntriesCompanion _toCompanion(
    Inspection insp, {
    required String syncStatus,
  }) {
    return InspectionEntriesCompanion(
      id: Value(insp.id),
      templateName: Value(insp.templateName),
      workOrderId: Value(insp.workOrderId),
      inspectorName: Value(insp.inspectorName),
      status: Value(insp.status.name),
      createdAt: Value(insp.createdAt),
      submittedBy: Value(insp.submittedBy),
      organizationId: Value(insp.organizationId),
      syncStatus: Value(syncStatus),
    );
  }

  static Map<String, dynamic> _toJson(Inspection insp) {
    return {
      'id': insp.id,
      'template_name': insp.templateName,
      'work_order_id': insp.workOrderId,
      'inspector_name': insp.inspectorName,
      'status': insp.status.name,
      'submitted_by': insp.submittedBy,
      'organization_id': insp.organizationId,
    };
  }

  static InspectionStatus _parseStatus(String? status) {
    return InspectionStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => InspectionStatus.draft,
    );
  }
}
