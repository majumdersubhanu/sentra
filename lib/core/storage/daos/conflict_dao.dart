import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'conflict_dao.g.dart';

@DriftAccessor(tables: [ConflictEntries])
class ConflictDao extends DatabaseAccessor<SentraDatabase>
    with _$ConflictDaoMixin {
  ConflictDao(super.db);

  /// Get all unresolved conflicts.
  Stream<List<ConflictEntry>> watchUnresolvedConflicts() =>
      (select(conflictEntries)..where((t) => t.resolved.equals(false))).watch();

  /// Upsert a conflict.
  Future<void> upsertConflict(ConflictEntriesCompanion entry) =>
      into(conflictEntries).insertOnConflictUpdate(entry);

  /// Mark a conflict as resolved.
  Future<void> resolveConflict(String id, String entityType) =>
      (update(conflictEntries)
            ..where((t) => t.id.equals(id) & t.entityType.equals(entityType)))
          .write(const ConflictEntriesCompanion(resolved: Value(true)));

  /// Get a specific conflict.
  Future<ConflictEntry?> getConflict(String id, String entityType) =>
      (select(conflictEntries)
            ..where((t) => t.id.equals(id) & t.entityType.equals(entityType)))
          .getSingleOrNull();

  /// Delete a conflict.
  Future<void> deleteConflict(String id, String entityType) => (delete(
    conflictEntries,
  )..where((t) => t.id.equals(id) & t.entityType.equals(entityType))).go();
}
