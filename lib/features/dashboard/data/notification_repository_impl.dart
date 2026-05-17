import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/storage/database.dart';
import '../domain/notification.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final SentraDatabase _db;

  NotificationRepositoryImpl(this._db);

  @override
  Future<Either<Failure, List<SentraNotification>>> getNotifications() async {
    try {
      final entries = await _db.notificationDao.getAllNotifications();
      return Right(entries.map(_fromEntry).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch notifications: $e'));
    }
  }

  @override
  Stream<List<SentraNotification>> watchUnreadNotifications() {
    return _db.notificationDao.watchUnreadNotifications().map(
      (entries) => entries.map(_fromEntry).toList(),
    );
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) async {
    try {
      await _db.notificationDao.markAsRead(id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to mark notification as read: $e'));
    }
  }

  SentraNotification _fromEntry(NotificationEntry entry) {
    return SentraNotification(
      id: entry.id,
      title: entry.title,
      message: entry.message,
      type: SentraNotificationType.values.firstWhere(
        (t) => t.name == entry.type,
        orElse: () => SentraNotificationType.system,
      ),
      entityType: entry.entityType,
      entityId: entry.entityId,
      createdAt: entry.createdAt,
      isRead: entry.isRead,
    );
  }
}
