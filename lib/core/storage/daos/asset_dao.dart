import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'asset_dao.g.dart';

@DriftAccessor(tables: [AssetEntries])
class AssetDao extends DatabaseAccessor<SentraDatabase> with _$AssetDaoMixin {
  AssetDao(super.db);

  /// Get all assets, ordered by creation date.
  Future<List<AssetEntry>> getAllAssets() => (select(
    assetEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  /// Watch all assets reactively.
  Stream<List<AssetEntry>> watchAllAssets() => (select(
    assetEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  /// Get a single asset by ID.
  Future<AssetEntry?> getById(String id) =>
      (select(assetEntries)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get assets by status.
  Future<List<AssetEntry>> getByStatus(String status) => (select(
    assetEntries,
  )..where((t) => t.operationalStatus.equals(status))).get();

  /// Get assets with pending sync.
  Future<List<AssetEntry>> getPendingSync() => (select(
    assetEntries,
  )..where((t) => t.syncStatus.equals('pending'))).get();

  /// Insert or replace an asset.
  Future<void> upsertAsset(AssetEntriesCompanion entry) =>
      into(assetEntries).insertOnConflictUpdate(entry);

  /// Bulk upsert from remote sync.
  Future<void> bulkUpsert(List<AssetEntriesCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(assetEntries, entry, onConflict: DoUpdate((_) => entry));
      }
    });
  }

  /// Delete an asset by ID.
  Future<int> deleteById(String id) =>
      (delete(assetEntries)..where((t) => t.id.equals(id))).go();

  /// Mark pending sync.
  Future<void> markPendingSync(String id) =>
      (update(assetEntries)..where((t) => t.id.equals(id))).write(
        const AssetEntriesCompanion(syncStatus: Value('pending')),
      );

  /// Mark synced.
  Future<void> markSynced(String id) =>
      (update(assetEntries)..where((t) => t.id.equals(id))).write(
        const AssetEntriesCompanion(syncStatus: Value('synced')),
      );

  /// Clear all assets.
  Future<void> clearAll() => delete(assetEntries).go();
}
