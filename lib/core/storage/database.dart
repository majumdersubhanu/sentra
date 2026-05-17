import 'package:drift/drift.dart';

import 'daos/asset_dao.dart';
import 'daos/inspection_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/work_order_dao.dart';
import 'daos/conflict_dao.dart';
import 'daos/user_dao.dart';
import 'daos/notification_dao.dart';
import 'db_connection.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    WorkOrderEntries,
    AssetEntries,
    InspectionEntries,
    InspectionItemEntries,
    WorkOrderCommentEntries,
    AttachmentEntries,
    SyncQueueEntries,
    ConflictEntries,
    UserEntries,
    NotificationEntries,
    WorkOrderMaterialEntries,
  ],
  daos: [
    WorkOrderDao,
    InspectionDao,
    AssetDao,
    SyncQueueDao,
    ConflictDao,
    UserDao,
    NotificationDao,
  ],
)
class SentraDatabase extends _$SentraDatabase {
  SentraDatabase() : super(_openConnection());

  /// For testing: allow injecting a custom executor.
  SentraDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Future schema migrations go here.
    },
  );

  // ─── DAO Accessors ────────────────────────────────────────────────────────

  @override
  WorkOrderDao get workOrderDao => WorkOrderDao(this);
  @override
  InspectionDao get inspectionDao => InspectionDao(this);
  @override
  AssetDao get assetDao => AssetDao(this);
  @override
  SyncQueueDao get syncQueueDao => SyncQueueDao(this);
  @override
  ConflictDao get conflictDao => ConflictDao(this);
  @override
  UserDao get userDao => UserDao(this);
  @override
  NotificationDao get notificationDao => NotificationDao(this);

  // ─── Utility ──────────────────────────────────────────────────────────────

  /// Wipe all local data (useful for sign-out).
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(syncQueueEntries).go();
      await delete(attachmentEntries).go();
      await delete(workOrderCommentEntries).go();
      await delete(inspectionItemEntries).go();
      await delete(inspectionEntries).go();
      await delete(assetEntries).go();
      await delete(workOrderEntries).go();
      await delete(notificationEntries).go();
      await delete(workOrderMaterialEntries).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(openDriftConnection);
}
