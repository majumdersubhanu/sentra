import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/env/env.dart';
import '../../../core/error/failures.dart';
import '../../../core/storage/database.dart';
import '../domain/inspection.dart';
import '../domain/inspection_repository.dart';

/// Network-aware repository for inspections.
@LazySingleton(as: InspectionRepository)
class InspectionRepositoryImpl implements InspectionRepository {
  final SentraDatabase _db;

  InspectionRepositoryImpl(this._db);

  static final List<Inspection> _mockInspections = [
    Inspection(
      id: 'INS-2001',
      templateName: 'HVAC Compliance Check',
      workOrderId: 'WO-1001',
      inspectorName: 'Subhanu',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: InspectionStatus.submitted,
      items: const [
        InspectionItem(
          id: 'Q1',
          question: 'Compressor oil level within operational range?',
          isPass: true,
          sortOrder: 0,
        ),
        InspectionItem(
          id: 'Q2',
          question: 'Evidence of refrigerant fluid leaks detected?',
          isPass: false,
          comments: 'Trace moisture near drain valve.',
          sortOrder: 1,
        ),
      ],
    ),
    Inspection(
      id: 'INS-2002',
      templateName: 'Transformer Safety Audit',
      workOrderId: 'WO-1002',
      inspectorName: 'Elena Rostova',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: InspectionStatus.approved,
      items: const [
        InspectionItem(
          id: 'Q1',
          question: 'Primary coil resistance matches manufacturer spec?',
          isPass: true,
          sortOrder: 0,
        ),
        InspectionItem(
          id: 'Q2',
          question: 'Cooling fins free of significant debris/obstruction?',
          isPass: true,
          sortOrder: 1,
        ),
      ],
    ),
  ];

  final List<Inspection> _localMockInspections = List.from(_mockInspections);

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<Inspection>>> getInspections() async {
    if (Env.bypassAuth) return Right(List.unmodifiable(_localMockInspections));

    try {
      final client = _client;
      if (client != null) {
        final response = await client
            .from('inspections')
            .select()
            .order('created_at', ascending: false);
        final inspections = (response as List)
            .map((json) => _fromJson(json as Map<String, dynamic>))
            .toList();
        _cacheToLocal(inspections);
        return Right(inspections);
      }
    } catch (_) {}

    try {
      final entries = await _db.inspectionDao.getAllInspections();
      final inspections = <Inspection>[];
      for (final entry in entries) {
        final items = await _db.inspectionDao.getItemsForInspection(entry.id);
        inspections.add(_fromEntry(entry, items));
      }
      return Right(inspections);
    } catch (e) {
      return Left(CacheFailure('Failed to read local cache: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveInspection(Inspection inspection) async {
    if (Env.bypassAuth) {
      final index = _localMockInspections.indexWhere(
        (i) => i.id == inspection.id,
      );
      if (index != -1) {
        _localMockInspections[index] = inspection;
      } else {
        _localMockInspections.add(inspection);
      }
      return const Right(unit);
    }

    try {
      // Write to Drift
      await _db.inspectionDao.upsertInspection(
        _toCompanion(inspection, syncStatus: 'pending'),
      );
      await _db.inspectionDao.replaceItems(
        inspection.id,
        inspection.items
            .map(
              (item) => InspectionItemEntriesCompanion(
                id: Value(item.id),
                inspectionId: Value(inspection.id),
                question: Value(item.question),
                isPass: Value(item.isPass),
                comments: Value(item.comments),
                sortOrder: Value(item.sortOrder),
              ),
            )
            .toList(),
      );

      // Enqueue sync
      await _db.syncQueueDao.enqueue(
        entityType: 'inspection',
        entityId: inspection.id,
        mutationType: 'upsert',
        payload: jsonEncode(_toJson(inspection)),
      );

      // Try immediate sync
      try {
        final client = _client;
        if (client != null) {
          await client.from('inspections').upsert(_toJson(inspection));
          await _db.inspectionDao.markSynced(inspection.id);
        }
      } catch (_) {}

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save inspection: $e'));
    }
  }

  Future<void> _cacheToLocal(List<Inspection> inspections) async {
    try {
      final companions = inspections
          .map((i) => _toCompanion(i, syncStatus: 'synced'))
          .toList();
      await _db.inspectionDao.bulkUpsert(companions);
    } catch (_) {}
  }

  static Inspection _fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] as String,
      templateName: json['template_name'] as String? ?? '',
      workOrderId: json['work_order_id'] as String? ?? '',
      inspectorName:
          json['inspector_name'] as String? ??
          json['template_name'] as String? ??
          '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      status: _parseStatus(json['status'] as String?),
      submittedBy: json['submitted_by'] as String?,
      organizationId: json['organization_id'] as String?,
      items: const [], // Items fetched separately
    );
  }

  static Inspection _fromEntry(
    InspectionEntry entry,
    List<InspectionItemEntry> items,
  ) {
    return Inspection(
      id: entry.id,
      templateName: entry.templateName,
      workOrderId: entry.workOrderId,
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
      'template_name': insp.templateName.isNotEmpty
          ? insp.templateName
          : insp.inspectorName,
      'work_order_id': insp.workOrderId.isNotEmpty ? insp.workOrderId : null,
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
