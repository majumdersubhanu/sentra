import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'inspection_dao.g.dart';

@DriftAccessor(tables: [InspectionEntries, InspectionItemEntries])
class InspectionDao extends DatabaseAccessor<SentraDatabase>
    with _$InspectionDaoMixin {
  InspectionDao(super.db);

  /// Get all inspections, ordered by creation date.
  Future<List<InspectionEntry>> getAllInspections() => (select(
    inspectionEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  /// Watch all inspections reactively.
  Stream<List<InspectionEntry>> watchAllInspections() => (select(
    inspectionEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  /// Get a single inspection by ID.
  Future<InspectionEntry?> getById(String id) => (select(
    inspectionEntries,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get checklist items for an inspection, ordered by sort_order.
  Future<List<InspectionItemEntry>> getItemsForInspection(
    String inspectionId,
  ) =>
      (select(inspectionItemEntries)
            ..where((t) => t.inspectionId.equals(inspectionId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  /// Get inspections with pending sync.
  Future<List<InspectionEntry>> getPendingSync() => (select(
    inspectionEntries,
  )..where((t) => t.syncStatus.equals('pending'))).get();

  /// Insert or replace an inspection.
  Future<void> upsertInspection(InspectionEntriesCompanion entry) =>
      into(inspectionEntries).insertOnConflictUpdate(entry);

  /// Insert or replace a checklist item.
  Future<void> upsertItem(InspectionItemEntriesCompanion item) =>
      into(inspectionItemEntries).insertOnConflictUpdate(item);

  /// Bulk upsert inspections from remote sync.
  Future<void> bulkUpsert(List<InspectionEntriesCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(inspectionEntries, entry, onConflict: DoUpdate((_) => entry));
      }
    });
  }

  /// Replace all items for an inspection.
  Future<void> replaceItems(
    String inspectionId,
    List<InspectionItemEntriesCompanion> items,
  ) async {
    await (delete(
      inspectionItemEntries,
    )..where((t) => t.inspectionId.equals(inspectionId))).go();
    await batch((b) {
      for (final item in items) {
        b.insert(inspectionItemEntries, item);
      }
    });
  }

  /// Delete an inspection and its items.
  Future<void> deleteById(String id) async {
    await (delete(
      inspectionItemEntries,
    )..where((t) => t.inspectionId.equals(id))).go();
    await (delete(inspectionEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Mark pending sync.
  Future<void> markPendingSync(String id) =>
      (update(inspectionEntries)..where((t) => t.id.equals(id))).write(
        const InspectionEntriesCompanion(syncStatus: Value('pending')),
      );

  /// Mark synced.
  Future<void> markSynced(String id) =>
      (update(inspectionEntries)..where((t) => t.id.equals(id))).write(
        const InspectionEntriesCompanion(syncStatus: Value('synced')),
      );

  /// Clear all.
  Future<void> clearAll() async {
    await delete(inspectionItemEntries).go();
    await delete(inspectionEntries).go();
  }
}
