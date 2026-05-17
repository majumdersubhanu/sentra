import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueueEntries])
class SyncQueueDao extends DatabaseAccessor<SentraDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Get all pending mutations (FIFO).
  Future<List<SyncQueueEntry>> getPendingMutations() =>
      (select(syncQueueEntries)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  /// Watch pending mutations count reactively.
  Stream<int> watchPendingCount() {
    final query = selectOnly(syncQueueEntries)
      ..where(syncQueueEntries.status.equals('pending'))
      ..addColumns([syncQueueEntries.id.count()]);
    return query
        .map((row) => row.read(syncQueueEntries.id.count()) ?? 0)
        .watchSingle();
  }

  /// Enqueue a new mutation.
  Future<int> enqueue({
    required String entityType,
    required String entityId,
    required String mutationType,
    required String payload,
  }) => into(syncQueueEntries).insert(
    SyncQueueEntriesCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      mutationType: mutationType,
      payload: payload,
    ),
  );

  /// Mark a mutation as in-progress.
  Future<void> markInProgress(int id) =>
      (update(syncQueueEntries)..where((t) => t.id.equals(id))).write(
        const SyncQueueEntriesCompanion(status: Value('in_progress')),
      );

  /// Mark a mutation as succeeded.
  Future<void> markSuccess(int id) =>
      (update(syncQueueEntries)..where((t) => t.id.equals(id))).write(
        SyncQueueEntriesCompanion(
          status: const Value('success'),
          processedAt: Value(DateTime.now()),
        ),
      );

  /// Mark a mutation as failed with error and increment retry count.
  Future<void> markFailed(int id, String errorMessage) async {
    final entry = await (select(
      syncQueueEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (entry == null) return;

    await (update(syncQueueEntries)..where((t) => t.id.equals(id))).write(
      SyncQueueEntriesCompanion(
        status: const Value('failed'),
        retryCount: Value(entry.retryCount + 1),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  /// Reset failed mutations back to pending for retry.
  Future<void> retryFailed() =>
      (update(syncQueueEntries)..where((t) => t.status.equals('failed'))).write(
        const SyncQueueEntriesCompanion(
          status: Value('pending'),
          errorMessage: Value(null),
        ),
      );

  /// Reset a single failed mutation to pending.
  Future<void> retryById(int id) =>
      (update(syncQueueEntries)..where((t) => t.id.equals(id))).write(
        const SyncQueueEntriesCompanion(
          status: Value('pending'),
          errorMessage: Value(null),
        ),
      );

  /// Purge completed/succeeded mutations older than the given age.
  Future<int> purgeCompleted({Duration olderThan = const Duration(days: 7)}) =>
      (delete(syncQueueEntries)..where(
            (t) =>
                t.status.equals('success') &
                t.processedAt.isSmallerThanValue(
                  DateTime.now().subtract(olderThan),
                ),
          ))
          .go();

  /// Get all entries (for debug/display).
  Future<List<SyncQueueEntry>> getAll() => (select(
    syncQueueEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  /// Clear entire queue.
  Future<void> clearAll() => delete(syncQueueEntries).go();

  /// Delete a pending mutation for a specific entity.
  Future<void> deleteMutation(String entityId, String entityType) =>
      (delete(syncQueueEntries)..where(
            (t) =>
                t.entityId.equals(entityId) & t.entityType.equals(entityType),
          ))
          .go();
}
