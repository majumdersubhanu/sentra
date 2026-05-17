import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [NotificationEntries])
class NotificationDao extends DatabaseAccessor<SentraDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  Future<List<NotificationEntry>> getAllNotifications() => (select(
    notificationEntries,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Stream<List<NotificationEntry>> watchUnreadNotifications() => (select(
    notificationEntries,
  )..where((t) => t.isRead.equals(false))).watch();

  Future<void> markAsRead(String id) =>
      (update(notificationEntries)..where((t) => t.id.equals(id))).write(
        const NotificationEntriesCompanion(isRead: Value(true)),
      );

  Future<void> upsertNotification(NotificationEntriesCompanion entry) =>
      into(notificationEntries).insertOnConflictUpdate(entry);

  Future<void> clearAll() => delete(notificationEntries).go();
}
