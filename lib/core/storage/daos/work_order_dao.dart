import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'work_order_dao.g.dart';

@DriftAccessor(tables: [WorkOrderEntries])
class WorkOrderDao extends DatabaseAccessor<SentraDatabase>
    with _$WorkOrderDaoMixin {
  WorkOrderDao(super.db);

  /// Get all work orders, ordered by creation date.
  Future<List<WorkOrderEntry>> getAllWorkOrders() => (select(
    workOrderEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  /// Watch all work orders reactively.
  Stream<List<WorkOrderEntry>> watchAllWorkOrders() => (select(
    workOrderEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  /// Get a single work order by ID.
  Future<WorkOrderEntry?> getById(String id) => (select(
    workOrderEntries,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get work orders by status.
  Future<List<WorkOrderEntry>> getByStatus(String status) =>
      (select(workOrderEntries)..where((t) => t.status.equals(status))).get();

  /// Get work orders with pending sync.
  Future<List<WorkOrderEntry>> getPendingSync() => (select(
    workOrderEntries,
  )..where((t) => t.syncStatus.equals('pending'))).get();

  /// Insert or replace a work order.
  Future<void> upsertWorkOrder(WorkOrderEntriesCompanion entry) =>
      into(workOrderEntries).insertOnConflictUpdate(entry);

  /// Bulk upsert from remote sync.
  Future<void> bulkUpsert(List<WorkOrderEntriesCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(workOrderEntries, entry, onConflict: DoUpdate((_) => entry));
      }
    });
  }

  /// Delete a work order by ID.
  Future<int> deleteById(String id) =>
      (delete(workOrderEntries)..where((t) => t.id.equals(id))).go();

  /// Mark a work order as needing sync.
  Future<void> markPendingSync(String id) =>
      (update(workOrderEntries)..where((t) => t.id.equals(id))).write(
        const WorkOrderEntriesCompanion(syncStatus: Value('pending')),
      );

  /// Mark a work order as synced.
  Future<void> markSynced(String id) =>
      (update(workOrderEntries)..where((t) => t.id.equals(id))).write(
        const WorkOrderEntriesCompanion(syncStatus: Value('synced')),
      );

  /// Clear all work orders (used during full refresh).
  Future<void> clearAll() => delete(workOrderEntries).go();
}
